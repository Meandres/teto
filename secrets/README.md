# Secrets

Encrypted secrets managed with [agenix](https://github.com/ryantm/agenix).

## One-time setup

1. **Generate the two keypairs** (on any machine):

   ```bash
   # L — personal key, lives on local machines only
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_l -C "ilya@local" -N ""
   # R — servers key, lives on mehve + TUM cluster
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_r -C "ilya@servers" -N ""
   ```

2. **Fill in `modules/pubkeys.nix`** with the contents of
   `~/.ssh/id_ed25519_l.pub` (as `L`) and `~/.ssh/id_ed25519_r.pub` (as `R`).

3. **Encrypt R's private key**:

   ```bash
   nix develop
   # paste the contents of ~/.ssh/id_ed25519_r into the editor that opens
   agenix -i ~/.ssh/id_ed25519_l -e secrets/ssh_r_private.age
   ```

4. **Copy L private key** to your other local machine (ohmu or teto)
   via a trusted channel (USB stick, 1Password, etc.):

   ```bash
   # on destination:
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   scp local-source:~/.ssh/id_ed25519_l* ~/.ssh/
   chmod 600 ~/.ssh/id_ed25519_l
   ```

5. **Install R's public key on the TUM cluster**:

   ```bash
   ssh-copy-id -i ~/.ssh/id_ed25519_l.pub ilya@<cluster-host>  # if not there yet
   ssh ilya@<cluster-host> 'cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_ed25519_r.pub
   # Also drop R's private key on each cluster host so agents can hop between them:
   scp ~/.ssh/id_ed25519_r ilya@<cluster-host>:~/.ssh/
   ```

## After mehve is installed

The mehve host's SSH host key is created at first boot. Harvest it and
re-encrypt R's private key so mehve can decrypt at activation:

```bash
ssh ilya@mehve sudo cat /etc/ssh/ssh_host_ed25519_key.pub
# paste the output into modules/pubkeys.nix as hostKeys.mehve
agenix -i ~/.ssh/id_ed25519_l -r
```

Then `just switch_os mehve` and the private key appears at
`~/.ssh/id_ed25519_r` on mehve.

## Editing a secret later

```bash
nix develop
agenix -i ~/.ssh/id_ed25519_l -e secrets/ssh_r_private.age
```

## Rotating R

If R is ever leaked:

1. Generate a new R.
2. Replace `R` in `modules/pubkeys.nix`.
3. Re-encrypt: `agenix -r`.
4. Replace the private file on each cluster host.
5. `just switch_os mehve`.
6. Remove the old pubkey from every cluster host's `authorized_keys`.
