#!/usr/bin/env python3
"""
Daily PR review poll.

Env:
  GH_TOKEN                 - GitHub token
  TELEGRAM_BOT_TOKEN       - for posting a summary to the PR topic
  TELEGRAM_GROUP_ID        - supergroup id
  TELEGRAM_PR_TOPIC_ID     - message_thread_id for the "PR Review" topic
  REVIEW_REPOS             - comma-separated owner/repo list
  AGENT_SCRATCH_ROOT
  AGENT_RUN_SCRIPT

For every open PR in each repo whose head SHA has changed since the last run,
spawns an agent-run with a PR-review prompt that drops the diff and asks for
findings; posts the agent's output back as a PR comment, and sends a short
status summary to the PR topic in Telegram.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

import requests

GH_TOKEN = os.environ["GH_TOKEN"]
BOT_TOKEN = os.environ["TELEGRAM_BOT_TOKEN"]
GROUP_ID = os.environ["TELEGRAM_GROUP_ID"]
PR_TOPIC = os.environ["TELEGRAM_PR_TOPIC_ID"]
REPOS = [r.strip() for r in os.environ["REVIEW_REPOS"].split(",") if r.strip()]
SCRATCH_ROOT = Path(os.environ["AGENT_SCRATCH_ROOT"])
RUN_SCRIPT = Path(os.environ["AGENT_RUN_SCRIPT"])

STATE_PATH = SCRATCH_ROOT / "pr-review" / "state.json"
STATE_PATH.parent.mkdir(parents=True, exist_ok=True)

SKILL_PROMPT = """You are reviewing a GitHub pull request.

The repo has been cloned into the current directory and the PR branch is checked out.
Review the diff below for correctness bugs, reuse/simplification opportunities, and
performance concerns. Be specific — reference files and line numbers. If nothing is
wrong, say so briefly. Keep the whole review under 400 words.

Diff:
{diff}
"""


def gh_api(path: str):
    r = requests.get(
        f"https://api.github.com{path}",
        headers={
            "Authorization": f"Bearer {GH_TOKEN}",
            "Accept": "application/vnd.github+json",
        },
        timeout=30,
    )
    r.raise_for_status()
    return r.json()


def load_state():
    if STATE_PATH.exists():
        return json.loads(STATE_PATH.read_text())
    return {}


def save_state(state):
    STATE_PATH.write_text(json.dumps(state, indent=2))


def notify(text: str):
    try:
        requests.post(
            f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage",
            json={
                "chat_id": int(GROUP_ID),
                "message_thread_id": int(PR_TOPIC),
                "text": text,
            },
            timeout=15,
        )
    except Exception as e:
        print(f"telegram notify failed: {e}", file=sys.stderr)


def review_pr(repo: str, pr: dict, scratch: Path) -> dict:
    diff = requests.get(
        pr["diff_url"],
        headers={"Authorization": f"Bearer {GH_TOKEN}"},
        timeout=60,
    ).text
    prompt = SKILL_PROMPT.format(diff=diff[:60000])  # safety cap
    task = f"pr-review:{repo}#{pr['number']}"
    cp = subprocess.run(
        [str(RUN_SCRIPT), task, str(scratch), prompt],
        capture_output=True,
        text=True,
    )
    body = cp.stdout.strip() or "(no review produced)"
    summary = {}
    for line in cp.stderr.splitlines():
        if line.startswith("SUMMARY:"):
            try:
                summary = json.loads(line[len("SUMMARY:"):])
            except Exception:
                pass
    # Post as a PR comment
    requests.post(
        f"https://api.github.com/repos/{repo}/issues/{pr['number']}/comments",
        headers={
            "Authorization": f"Bearer {GH_TOKEN}",
            "Accept": "application/vnd.github+json",
        },
        json={"body": f"🤖 Automated review\n\n{body}"},
        timeout=30,
    )
    return summary


def main():
    state = load_state()
    total_reviewed = 0
    total_cost = 0.0
    for repo in REPOS:
        prs = gh_api(f"/repos/{repo}/pulls?state=open")
        for pr in prs:
            key = f"{repo}#{pr['number']}"
            head = pr["head"]["sha"]
            if state.get(key) == head:
                continue  # unchanged since last check
            scratch = SCRATCH_ROOT / "pr-review" / repo.replace("/", "-") / str(pr["number"])
            scratch.mkdir(parents=True, exist_ok=True)
            summary = review_pr(repo, pr, scratch)
            state[key] = head
            total_reviewed += 1
            total_cost += float(summary.get("cost_usd", 0))
            notify(
                f"✅ Reviewed {key} ({pr['title'][:60]})\n"
                f"${summary.get('cost_usd', 0):.4f} · "
                f"in={summary.get('input_tokens', 0)} out={summary.get('output_tokens', 0)}"
            )
    save_state(state)
    if total_reviewed == 0:
        notify("☀️ Daily PR poll: nothing new.")
    else:
        notify(f"📬 Daily poll done. Reviewed {total_reviewed} PR(s). Total cost ${total_cost:.3f}.")


if __name__ == "__main__":
    main()
