{ pkgs, stdenv }:
{
	i3exit-bin = pkgs.stdenv.mkDerivation {
  	pname = "i3exit-wrapper";
  	version = "1.0";

  	src = null;

  	buildInputs = [ pkgs.i3lock pkgs.systemd ];

  	installPhase = ''
    	mkdir -p $out/bin
    	cat > $out/bin/i3exit <<EOF
			#!/bin/bash
			case "\$1" in
    		lock)
        	i3lock
        	;;
    		suspend)
        	i3lock && systemctl suspend
        	;;
    		reboot)
        	systemctl reboot
        	;;
    		shutdown)
        	systemctl poweroff
        	;;
    		*)
        	echo "== ! i3exit: missing or invalid argument ! =="
        	echo "Try again with: lock | logout | switch_user | suspend | hibernate | reboot | shutdown"
        	exit 2
        	;;
			esac
			exit 0
			EOF
    	chmod +x $out/bin/i3exit
  	'';

  	meta = with pkgs.lib; {
    	description = "A wrapper for i3lock to handle locking, suspending, rebooting, and shutting down.";
    	license = licenses.mit;
    	platforms = platforms.linux;
  	};
	};
}
