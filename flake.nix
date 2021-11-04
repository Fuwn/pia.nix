{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05"; };
  outputs = { self, nixpkgs }: {
    nixosModule = { lib, config, ... }: {
      options = {
        services.pia = {
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
      };
      config = nixpkgs.lib.mkIf config.services.pia.enable {
        services.openvpn.servers = let
          resources = nixpkgs.legacyPackages.x86_64-linux.fetchzip {
            name = "pia-vpn-config";
            url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
            sha256 = "ZA8RS6eIjMVQfBt+9hYyhaq8LByy5oJaO9Ed+x8KtW8=";
            stripRoot = false;
          };
          fixup = (builtins.replaceStrings [ ".ovpn" "_" ] [ "" "-" ]);
          servers =
            (builtins.filter (name: !(isNull (builtins.match ".+ovpn$" name)))
              (builtins.attrNames (builtins.readDir resources)));
          make_server = (name: {
            name = fixup name;
            value = {
              autoStart = false;
              authUserPass = config.services.pia.authUserPass;
              config = "config ${resources}/${name}";
              updateResolvConf = true;
            };
          });
        in builtins.listToAttrs (map make_server servers);
      };
    };
  };
}
