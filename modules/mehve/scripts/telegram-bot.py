#!/usr/bin/env python3
"""
mehve agent control bot.

Config via env:
  TELEGRAM_BOT_TOKEN      - bot token from BotFather
  TELEGRAM_ALLOWED_USER   - integer Telegram user ID allowed to use the bot
  TELEGRAM_GROUP_ID       - integer chat ID of the supergroup (negative, like -100…)
  AGENT_DB                - sqlite db path
  AGENT_SCRATCH_ROOT      - root dir for per-topic scratch dirs
  AGENT_RUN_SCRIPT        - path to agent-run.sh
  SKILLS_DIR              - path to user ~/.claude/skills
  MAX_CONCURRENT          - int (default 3)
  MESSAGE_SPLIT_CHARS     - int (default 3800)

Behaviour:
  - Only messages in the configured supergroup, from the allowed user, are processed.
  - Each topic (message_thread_id) owns a scratch dir and claude session history.
  - Messages in a topic are treated as prompts to that session.
  - Slash commands: /status /cost /run /skills /logs
"""
from __future__ import annotations

import asyncio
import json
import logging
import os
import sqlite3
from datetime import datetime, timezone, timedelta
from pathlib import Path

from telegram import Update
from telegram.ext import (
    Application,
    CommandHandler,
    MessageHandler,
    ContextTypes,
    filters,
)

TOKEN = os.environ["TELEGRAM_BOT_TOKEN"]
ALLOWED_USER = int(os.environ["TELEGRAM_ALLOWED_USER"])
GROUP_ID = int(os.environ["TELEGRAM_GROUP_ID"])
DB_PATH = Path(os.environ["AGENT_DB"])
SCRATCH_ROOT = Path(os.environ["AGENT_SCRATCH_ROOT"])
RUN_SCRIPT = Path(os.environ["AGENT_RUN_SCRIPT"])
SKILLS_DIR = Path(os.environ.get("SKILLS_DIR", str(Path.home() / ".claude/skills")))
MAX_CONCURRENT = int(os.environ.get("MAX_CONCURRENT", "3"))
SPLIT = int(os.environ.get("MESSAGE_SPLIT_CHARS", "3800"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("mehve-bot")

semaphore = asyncio.Semaphore(MAX_CONCURRENT)
SCRATCH_ROOT.mkdir(parents=True, exist_ok=True)


def allowed(update: Update) -> bool:
    if update.effective_user is None or update.effective_user.id != ALLOWED_USER:
        return False
    if update.effective_chat is None or update.effective_chat.id != GROUP_ID:
        return False
    return True


def topic_scratch(topic_id: int) -> Path:
    d = SCRATCH_ROOT / f"topic-{topic_id}"
    d.mkdir(parents=True, exist_ok=True)
    return d


async def run_agent(task: str, scratch: Path, prompt: str) -> tuple[str, dict]:
    async with semaphore:
        proc = await asyncio.create_subprocess_exec(
            str(RUN_SCRIPT), task, str(scratch), prompt,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            env={**os.environ, "AGENT_DB": str(DB_PATH)},
        )
        stdout_b, stderr_b = await proc.communicate()
    text = stdout_b.decode(errors="replace").strip()
    summary = {}
    for line in stderr_b.decode(errors="replace").splitlines():
        if line.startswith("SUMMARY:"):
            try:
                summary = json.loads(line[len("SUMMARY:"):])
            except Exception:
                pass
    return text, summary


async def reply_split(update: Update, body: str, summary: dict | None = None):
    if not body:
        body = "(no output)"
    chunks = [body[i:i + SPLIT] for i in range(0, len(body), SPLIT)]
    for chunk in chunks:
        await update.effective_message.reply_text(chunk)
    if summary:
        footer = (
            f"💰 ${summary.get('cost_usd', 0):.4f}  "
            f"🪙 in={summary.get('input_tokens', 0)} out={summary.get('output_tokens', 0)}  "
            f"✅ {summary.get('status', '?')}"
        )
        await update.effective_message.reply_text(footer)


async def on_text(update: Update, _ctx: ContextTypes.DEFAULT_TYPE):
    if not allowed(update):
        return
    msg = update.effective_message
    topic = msg.message_thread_id
    if topic is None:
        return  # ignore non-topic messages
    prompt = msg.text or ""
    scratch = topic_scratch(topic)
    task = f"interactive:{topic}"
    log.info("topic=%s task=%s prompt=%r", topic, task, prompt[:60])
    try:
        text, summary = await run_agent(task, scratch, prompt)
    except Exception as e:
        log.exception("agent failed")
        await msg.reply_text(f"⚠️ agent error: {e}")
        return
    await reply_split(update, text, summary)


# ---------- slash commands ----------
def db():
    return sqlite3.connect(DB_PATH)


async def cmd_status(update: Update, _ctx: ContextTypes.DEFAULT_TYPE):
    if not allowed(update):
        return
    with db() as c:
        rows = c.execute(
            "SELECT started_at, task, status, cost_usd FROM runs ORDER BY id DESC LIMIT 10"
        ).fetchall()
    if not rows:
        await update.effective_message.reply_text("No runs yet.")
        return
    lines = [f"{r[0]}  {r[1]}  {r[2]}  ${r[3]:.3f}" for r in rows]
    await update.effective_message.reply_text("Recent runs:\n" + "\n".join(lines))


async def cmd_cost(update: Update, _ctx: ContextTypes.DEFAULT_TYPE):
    if not allowed(update):
        return
    now = datetime.now(timezone.utc)
    today_cutoff = now.replace(hour=0, minute=0, second=0, microsecond=0).isoformat()
    week_cutoff = (now - timedelta(days=7)).isoformat()
    with db() as c:
        day = c.execute(
            "SELECT COALESCE(SUM(cost_usd), 0) FROM runs WHERE started_at >= ?",
            (today_cutoff,),
        ).fetchone()[0]
        week = c.execute(
            "SELECT COALESCE(SUM(cost_usd), 0) FROM runs WHERE started_at >= ?",
            (week_cutoff,),
        ).fetchone()[0]
    await update.effective_message.reply_text(
        f"Today: ${day:.3f}\nLast 7 days: ${week:.3f}"
    )


async def cmd_skills(update: Update, _ctx: ContextTypes.DEFAULT_TYPE):
    if not allowed(update):
        return
    if not SKILLS_DIR.exists():
        await update.effective_message.reply_text("No skills dir.")
        return
    names = sorted(p.name for p in SKILLS_DIR.iterdir() if p.is_dir())
    if not names:
        await update.effective_message.reply_text("No skills installed.")
        return
    await update.effective_message.reply_text("Skills:\n" + "\n".join(names))


async def cmd_logs(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    if not allowed(update):
        return
    pattern = " ".join(ctx.args) if ctx.args else ""
    with db() as c:
        if pattern:
            rows = c.execute(
                "SELECT started_at, task, status, cost_usd FROM runs "
                "WHERE task LIKE ? ORDER BY id DESC LIMIT 20",
                (f"%{pattern}%",),
            ).fetchall()
        else:
            rows = c.execute(
                "SELECT started_at, task, status, cost_usd FROM runs ORDER BY id DESC LIMIT 20"
            ).fetchall()
    if not rows:
        await update.effective_message.reply_text("No matching runs.")
        return
    lines = [f"{r[0]}  {r[1]}  {r[2]}  ${r[3]:.3f}" for r in rows]
    await reply_split(update, "\n".join(lines))


async def cmd_run(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    """Kick off a one-off run in the current topic's session."""
    if not allowed(update):
        return
    if not ctx.args:
        await update.effective_message.reply_text("Usage: /run <prompt>")
        return
    msg = update.effective_message
    topic = msg.message_thread_id
    if topic is None:
        await update.effective_message.reply_text("Use /run inside a topic.")
        return
    prompt = " ".join(ctx.args)
    scratch = topic_scratch(topic)
    task = f"run:{topic}"
    try:
        text, summary = await run_agent(task, scratch, prompt)
    except Exception as e:
        await msg.reply_text(f"⚠️ agent error: {e}")
        return
    await reply_split(update, text, summary)


def main():
    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("status", cmd_status))
    app.add_handler(CommandHandler("cost", cmd_cost))
    app.add_handler(CommandHandler("skills", cmd_skills))
    app.add_handler(CommandHandler("logs", cmd_logs))
    app.add_handler(CommandHandler("run", cmd_run))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, on_text))
    log.info("starting bot (group=%s user=%s)", GROUP_ID, ALLOWED_USER)
    app.run_polling(allowed_updates=Update.ALL_TYPES)


if __name__ == "__main__":
    main()
