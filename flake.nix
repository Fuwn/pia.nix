{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs =
    { nixpkgs, self }:
    {
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
            services.openvpn.servers =
              let
                resources = nixpkgs.legacyPackages.x86_64-linux.fetchzip {
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
                    builtins.filter (name: !((builtins.match ".+ovpn$" name) == null)) (
                      builtins.attrNames (builtins.readDir resources)
                    )
                  )
              );
          };
        };
    };
}
