{ lib, pkgs }:
let
  inherit (lib) getExe;
in
pkgs.writeShellScriptBin "pia" ''
  ID=$(${pkgs.coreutils}/bin/id -u)

  if [ "$ID" -ne 0 ]; then
    if [ -x $(command -v doas) ]; then
      exec doas "$0" "$@"
    else
      exec sudo "$0" "$@"
    fi
  fi

  COMMAND="$1"
  LOCATION="$2"

  list() {
  	${getExe pkgs.findutils} /etc/systemd/system/ -name 'openvpn-*.service' -exec ${pkgs.coreutils}/bin/basename {} .service \; |
  		sed 's/openvpn-//'
  }

  search() {
  	list | ${getExe pkgs.fzf}
  }

  search_location() {
  	if [ -z "$LOCATION" ]; then
  		LOCATION=$(search)
  	fi
  }

  case "$COMMAND" in
  "start")
  	search_location
  	sudo systemctl start "openvpn-$LOCATION.service"
  	;;
  "stop")
  	search_location
    sudo systemctl stop "openvpn-$LOCATION.service"
  	;;
  "list")
  	list
  	;;
  "search")
  	search
  	;;
  *)
  	${pkgs.coreutils}/bin/echo "usage: $0 <start|stop|list|search>"
  	exit 1
  	;;
  esac
''
