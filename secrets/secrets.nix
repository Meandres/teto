let
  pubkeys = import ../modules/pubkeys.nix;
  inherit (pubkeys) L hostKeys;
  # Drop placeholder keys so re-keying works incrementally as pubkeys.nix fills in.
  real = key: builtins.match ".*REPLACE.*" key == null;
  keep = builtins.filter real;
in
{
  "ssh_r_private.age".publicKeys = keep [ L hostKeys.mehve ];
}
