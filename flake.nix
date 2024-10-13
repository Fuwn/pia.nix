{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs =
    {
      flake-utils,
      nixpkgs,
      self,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        lib = pkgs.lib;
      in
      {
        packages =
          let
            makeShellScript =
              name: action:
              pkgs.writeScriptBin name ''
                #!${pkgs.runtimeShell}

                if [ "$(id -u)" -ne 0 ]; then
                  exec sudo "$0" "$@"
                fi

                ${action}
              '';
          in
          {
            pia-start = makeShellScript "pia-start" "sudo systemctl start openvpn-$1.service";
            pia-stop = makeShellScript "pia-stop" "sudo systemctl stop openvpn-$1.service";
            pia-list = makeShellScript "pia-list" "ls /etc/systemd/system/ | awk '/openvpn/ {gsub(/openvpn-|.service/, \"\"); print}'";

            pia-search = makeShellScript "pia-search" "${
              lib.getExe self.packages.${system}.pia-list
            } | ${lib.getExe pkgs.fzf}";
          };

        nixosModules.default =
          { config, ... }:
          {
            options.services.pia = {
              enable = nixpkgs.lib.mkOption {
                default = false;
                type = nixpkgs.lib.types.bool;
              };

              authUserPass = {
                username = nixpkgs.lib.mkOption {
                  default = false;
                  type = nixpkgs.lib.types.str;
                };

                password = nixpkgs.lib.mkOption {
                  default = false;
                  type = nixpkgs.lib.types.str;
                };
              };
            };

            config = nixpkgs.lib.mkIf config.services.pia.enable {
              environment.systemPackages =
                let
                  piaPackages = self.packages.${system};
                in
                [
                  piaPackages.pia-start
                  piaPackages.pia-stop
                  piaPackages.pia-list
                  piaPackages.pia-search
                ];

              services.openvpn.servers =
                let
                  resources = nixpkgs.legacyPackages.${system}.fetchzip {
                    name = "pia-vpn-config";
                    url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
                    sha256 = "ZA8RS6eIjMVQfBt+9hYyhaq8LByy5oJaO9Ed+x8KtW8=";
                    stripRoot = false;
                  };
                in
                builtins.listToAttrs (
                  map
                    (name: {
                      name =
                        (builtins.replaceStrings
                          [
                            ".ovpn"
                            "_"
                          ]
                          [
                            ""
                            "-"
                          ]
                        )
                          name;

                      value = {
                        inherit (config.services.pia) authUserPass;

                        autoStart = false;
                        config = "config ${resources}/${name}";
                        updateResolvConf = true;
                      };
                    })
                    (
                      builtins.filter (name: (builtins.match ".+ovpn$" name) != null) (
                        builtins.attrNames (builtins.readDir resources)
                      )
                    )
                );
            };
          };
      }
    );
}
