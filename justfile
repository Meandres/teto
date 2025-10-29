cluster_node_setup:
	#!/usr/bin/env bash
	sudo mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
	sudo chown -R $USER /nix/var/nix/{profiles,gcroots}/per-user/$USER

switch_hm:
	#!/usr/bin/env bash
	home-manager switch --flake .#ilya

switch_os:
	#!/usr/bin/env bash
	sudo nixos-rebuild switch --flake .#teto
