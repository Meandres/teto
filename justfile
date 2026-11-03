cluster_node_setup:
	#!/usr/bin/env bash
	sudo mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
	sudo chown -R $USER /nix/var/nix/{profiles,gcroots}/per-user/$USER

switch_hm:
	#!/usr/bin/env bash
	home-manager switch --flake .#ilya

switch_os host=`hostname`:
	#!/usr/bin/env bash
	sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#{{host}} --impure

# Build the installer ISO (output appears under ./result/iso/).
build_iso:
	#!/usr/bin/env bash
	nix build .#nixosConfigurations.installer.config.system.build.isoImage
	ls -lh result/iso/

# Write the built ISO to a USB stick. Pass the device, e.g. `just flash_iso /dev/sdX`.
flash_iso device:
	#!/usr/bin/env bash
	set -euo pipefail
	iso=$(ls result/iso/*.iso | head -n1)
	echo "Flashing $iso to {{device}} — all data on {{device}} will be destroyed."
	read -p "Type YES to continue: " confirm
	[ "$confirm" = "YES" ] || { echo "Aborted."; exit 1; }
	sudo dd if="$iso" of={{device}} bs=4M status=progress conv=fsync
	sync

# Generate the L and R keypairs under ~/.ssh.
generate_keys:
	#!/usr/bin/env bash
	set -euo pipefail
	for name in l r; do
		path="$HOME/.ssh/id_ed25519_$name"
		if [ -f "$path" ]; then
			echo "Skipping $path — already exists."
		else
			ssh-keygen -t ed25519 -f "$path" -C "ilya@$name" -N ""
			echo "Generated $path"
		fi
	done
	echo
	echo "Public keys to paste into modules/pubkeys.nix:"
	echo "  L = \"$(cat ~/.ssh/id_ed25519_l.pub)\";"
	echo "  R = \"$(cat ~/.ssh/id_ed25519_r.pub)\";"

# Edit an agenix-encrypted secret.
edit_secret name:
	#!/usr/bin/env bash
	cd secrets && nix run github:ryantm/agenix -- -i ~/.ssh/id_ed25519_l -e {{name}}.age

# Re-encrypt all secrets after changing pubkeys.nix.
rekey_secrets:
	#!/usr/bin/env bash
	cd secrets && nix run github:ryantm/agenix -- -i ~/.ssh/id_ed25519_l -r
