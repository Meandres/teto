rec {
  L = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINx1B6kJNOk6J8e0lc67AVBLkuMilNEnIcmalsyhrgD ilya@l";
  R = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKw6iWPT5dTe4X7JJFNNB4+8q/j4rFMjpl4pRB/V/LF7 ilya@r";

  hostKeys = {
    mehve = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8sP3C2lLz4JSgjSNZz8LzC6DCNmJzkxuJNgcEz4KiG root@mehve";
  };

  users = [ L R ];
  localOnly = [ L ];
  serversOnly = [ R ];
}
