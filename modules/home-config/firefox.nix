{ pkgs, username, ... }:
{
  home.sessionVariables.MOZ_DBUS_REMOTE = "1";

  programs.firefox = {
    enable = true;
    profiles.default = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        simple-translate
        sponsorblock
        grammarly
      ] ++ [ pkgs.nur.repos.rycee.firefox-addons."7tv" ];
      settings = {
        "browser.download.dir"        = "/home/${username}/misc/firefox_downloads";
        "browser.download.folderList" = 2;
        "browser.download.useDownloadDir" = true;
      };
    };
  };
}
