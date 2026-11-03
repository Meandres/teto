identityFile:
{ lib, username, ... }:
let
  tumAliases = [
    "adelaide" "amy" "astrid" "bill" "clara" "christina" "dan" "graham"
    "ian" "irene" "jack" "jackson" "mickey" "nardole" "river" "rose" "ryan"
    "vislor" "wilfred" "yasmin" "xavier" "jamie" "martha" "tegan" "eliza"
    "joy" "steve" "polly"
  ];
  mkTumAlias = alias: {
    name = alias;
    value = {
      hostname = "${alias}.dos.cit.tum.de";
      user = username;
      forwardAgent = true;
      proxyJump = "tunnel";
      inherit identityFile;
      identitiesOnly = true;
    };
  };
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = (lib.listToAttrs (map mkTumAlias tumAliases)) // {
      tunnel = {
        hostname = "login.dos.cit.tum.de";
        user = "tunnel";
      };
      mehve = {
        hostname = "mehve.dos.cit.tum.de";
        user = username;
        inherit identityFile;
        identitiesOnly = true;
      };
      "*.dos.cit.tum.de" = {
        user = username;
        forwardAgent = true;
        proxyJump = "tunnel";
        inherit identityFile;
        identitiesOnly = true;
      };
      ace = {
        hostname = "ace.dos.cit.tum.de";
        user = username;
      };
      jumpy = {
        hostname = "i13vm10.in.tum.de";
        user = "meignanmasson";
      };
      genoa = {
        hostname = "genoa.pxe.dis.cit.tum.de";
        user = "meignanmasson";
        proxyJump = "jumpy";
      };
      clockwork = {
        hostname = "clockwork.dos.cit.tum.de";
        user = username;
        addressFamily = "inet";
      };
    };
  };
}
