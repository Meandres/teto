cluster_hosts := "node1.dos.cit.tum.de node2.dos.cit.tum.de"

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

switch_cluster:
	#!/usr/bin/env bash
	set -e
	for host in {{cluster_hosts}}; do
		echo "=== $host ==="
		ssh "$host" "nix run github:nix-community/home-manager -- switch --flake github:Meandres/teto#ilya --refresh"
	done

build_iso:
	#!/usr/bin/env bash
	nix build .#nixosConfigurations.installer.config.system.build.isoImage
	ls -lh result/iso/

flash_iso device:
	#!/usr/bin/env bash
	set -euo pipefail
	iso=$(ls result/iso/*.iso | head -n1)
	echo "Flashing $iso to {{device}} — all data on {{device}} will be destroyed."
	read -p "Type YES to continue: " confirm
	[ "$confirm" = "YES" ] || { echo "Aborted."; exit 1; }
	sudo dd if="$iso" of={{device}} bs=4M status=progress conv=fsync
	sync

edit_secret name:
	#!/usr/bin/env bash
	cd secrets && nix run github:ryantm/agenix -- -i ~/.ssh/id_ed25519_l -e {{name}}.age

rekey_secrets:
	#!/usr/bin/env bash
	cd secrets && nix run github:ryantm/agenix -- -i ~/.ssh/id_ed25519_l -r
