{ pkgs, lib, ... }: 
{
	config.xsession.windowManager.i3 = {
		enable = true;
		package = pkgs.i3-gaps;

		config = rec {
			modifier = "Mod1";
			bars = [];

			window.border = 0;

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
			
			gaps = {
				inner = 14;
				outer = -2;
				smartGaps = true;
			};

			menu = "${pkgs.rofi}/bin/rofi";
			
			keybindings = lib.mkOptionDefault {
				"${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
				"${modifier}+Shift+q" = "kill";
				"${modifier}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -theme solarized -font 'hack 10' -icon-theme 'Papirus' -show-icons";
				"XF86AudioMute" = "exec amixer set Master toggle";
        "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
        "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
				"${modifier}+Ctrl+Right" = "move workspace to output right";
				"${modifier}+Ctrl+Left" = "move workspace to output left";
				"${modifier}+Ctrl+Up" = "move workspace to output up";
				"${modifier}+Ctrl+Down" = "move workspace to output down";
				"${modifier}+Ctrl+l" = "exec --no-startup-id ${pkgs.i3lock}/bin/i3lock";
				"${modifier}+Ctrl+Shift+s" = "exec --no-startup-id systemctl poweroff";
				"${modifier}+Ctrl+Shift+r" = "exec --no-startup-id systemctl reboot";
				"${modifier}+Ctrl+s" = "exec --no-startup-id ${pkgs.i3lock}/bin/i3lock && systemctl suspend";
			};
		};
		
		extraConfig = ''
			assign [class="Thunderbird"] $ws2
			assign [class="Slack"] $ws3
			assign [class="Spotify"] $ws2
			assign [class="Discord"] $ws8

			for_window [title="alsamixer"] floating enable border pixel 1
			for_window [class="calamares"] floating enable border normal
			for_window [class="Clipgrab"] floating enable
			for_window [title="File Transfer*"] floating enable
			for_window [class="fpakman"] floating enable
			for_window [class="Galculator"] floating enable border pixel 1
			for_window [class="GParted"] floating enable border normal
			for_window [title="i3_help"] floating enable sticky enable border normal
			for_window [class="Lightdm-settings"] floating enable
			for_window [class="Lxappearance"] floating enable sticky enable border normal
			for_window [title="MuseScore: Play Panel"] floating enable
			for_window [class="Nitrogen"] floating enable sticky enable border normal
			for_window [class="Oblogout"] fullscreen enable
			for_window [class="octopi"] floating enable
			for_window [class="Pavucontrol"] floating enable
			for_window [class="qt5ct"] floating enable sticky enable border normal
			for_window [class="Qtconfig-qt4"] floating enable sticky enable border normal
			for_window [class="Simple-scan"] floating enable border normal
			for_window [class="(?i)System-config-printer.py"] floating enable border normal
			for_window [class="Timeset-gui"] floating enable border normal
			for_window [class="(?i)virtualbox"] floating enable border normal
			for_window [class="Xfburn"] floating enable

			for_window [urgent=latest] focus
		'';
	};
}
