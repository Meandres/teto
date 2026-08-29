{ pkgs, lib, ... }:
let
  powermenu = pkgs.writeShellScript "powermenu" ''
    choice=$(printf "Lock\nSuspend\nReboot\nShutdown" | ${pkgs.rofi}/bin/rofi -dmenu -p " Power:")
    case "$choice" in
      Lock)     ${pkgs.i3lock}/bin/i3lock ;;
      Suspend)  ${pkgs.i3lock}/bin/i3lock && systemctl suspend ;;
      Reboot)   systemctl reboot ;;
      Shutdown) systemctl poweroff ;;
    esac
  '';
in
{
	config.xsession.windowManager.i3 = {
		enable = true;
		package = pkgs.i3;

		config = rec {
			modifier = "Mod1";
			bars = [];

			window = {
				titlebar = false;
				border = 1;
			};

			terminal = "alacritty";

			colors = {
      	background = "#2B2C2B";
				focused = {
					background = "#556064";
					border = "#556064";
					text = "#80FFF9";
					indicator = "#FDF6E3"; 
					childBorder = "#285577";
				};
				focusedInactive = {
					background = "#2F3D44";
					border = "#2F4D44";
					text = "#1ABC9C";
					indicator = "#454948"; 
					childBorder = "#285577";
				};
				unfocused = {
					background = "#2F3D44";
					border = "#2F4D44";
					text = "#1ABC9C";
					indicator = "#454948"; 
					childBorder = "#285577";
				};
				urgent = {
					background = "#CB4B16";
					border = "#FDF6E3";
					text = "#1ABC9C";
					indicator = "#268BD2"; 
					childBorder = "#285577";
				};
				placeholder = {
					background = "#000000";
					border = "#0C0C0C";
					text = "#FFFFFF";
					indicator = "#000000";
					childBorder = "#285577";
				};	
			};

			defaultWorkspace = "workspace number 1";

			menu = "${pkgs.rofi}/bin/rofi";
			
			keybindings = lib.mkOptionDefault {
				"${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
				"${modifier}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show drun -modi drun";
				"${modifier}+Shift+f" = "exec flameshot gui";
				"XF86AudioMute" = "exec amixer set Master toggle";
        "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
        "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
				"${modifier}+Ctrl+Right" = "move workspace to output right";
				"${modifier}+Ctrl+Left" = "move workspace to output left";
				"${modifier}+Ctrl+Up" = "move workspace to output up";
				"${modifier}+Ctrl+Down" = "move workspace to output down";
				"${modifier}+Shift+e" = "exec --no-startup-id ${powermenu}";
			};
      floating = {
        criteria = [
			    { title="alsamixer"; }
          { class="Clipgrab"; }
			    { title="File Transfer*"; }
			    { class="Galculator"; }
			    { class="GParted"; }
          { class="Lightdm-settings"; }
			    { class="Lxappearance"; }
			    { title="MuseScore: Play Panel"; }
			    { class="Pavucontrol"; }
			    { title="Contrôle du volume"; }
        ];
        border = 1;
      };
		};
		
		extraConfig = ''
			for_window [urgent=latest] focus
			default_border pixel 1
			default_floating_border pixel 1
		'';
	};
}
