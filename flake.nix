{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05"; };
  outputs = { self, nixpkgs }: {
    nixosModule = { config }: {
      options = {
        services.pia.authUserPass = {
          enable = nixpkgs.lib.mkOption {
            default = false;
            type = nixpkgs.lib.types.bool;
          };
          username = nixpkgs.lib.mkOption {
            default = false;
            type = nixpkgs.lib.types.string;
          };
          password = nixpkgs.lib.mkOption {
            default = false;
            type = nixpkgs.lib.types.string;
          };
        };
      };
      config = nixpkgs.lib.mkIf config.services.pia.enable {
        services.openvpn.servers = let
          resources = nixpkgs.fetchzip {
            name = "pia-vpn-config";
            url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
            sha256 = "ZA8RS6eIjMVQfBt+9hYyhaq8LByy5oJaO9Ed+x8KtW8=";
            stripRoot = false;
          };
          servers = map (builtins.replaceStrings [ ".ovpn" "_" ] [ "" "-" ])
            (builtins.filter (name: !(isNull (builtins.match ".+ovpn$" name)))
              (builtins.attrNames (builtins.readDir resources)));
          make_server = (name: {
            name = name;
            value = {
              autoStart = false;
              authUserPass = config.services.pia.authUserPass;
              config = "config ${resources}/${name}.ovpn";
              updateResolvConf = true;
            };
          });
        in builtins.listToAttrs (map make_server servers);
      };
    };
  };
}
