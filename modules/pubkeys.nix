rec {
  L = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINx1B6kJNOk6J8e0lc67AVBLkuMilNEnIcmalsyhrgD ilya@l";
  R = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKw6iWPT5dTe4X7JJFNNB4+8q/j4rFMjpl4pRB/V/LF7 ilya@r";

  hostKeys = {
    mehve = "ssh-ed25519 AAAA_REPLACE_WITH_MEHVE_HOST_PUB root@mehve";
  };

  users = [ L R ];
  localOnly = [ L ];
  serversOnly = [ R ];
}
