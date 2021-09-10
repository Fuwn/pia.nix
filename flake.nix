{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    home-manager.url = "github:rycee/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager }: {
    lib.enableSwaybar = { config, pkgs, ... }:
      let
        colors = config.colors;
        background = "#${colors.base00}";
        brite_bg = "#${colors.base01}";
        dim = "#${colors.base04}";
        fg = "#${colors.base05}";
        brite = "#${colors.base07}";
      in {
        wayland.windowManager.sway.config.bars = [{
          colors.background = background;
          colors.statusline = fg;
          colors.activeWorkspace.background = background;
          colors.activeWorkspace.border = background;
          colors.activeWorkspace.text = fg;
          colors.focusedWorkspace.background = background;
          colors.focusedWorkspace.border = background;
          colors.focusedWorkspace.text = brite;
          colors.inactiveWorkspace.background = background;
          colors.inactiveWorkspace.border = background;
          colors.inactiveWorkspace.text = dim;
          colors.urgentWorkspace.background = fg;
          colors.urgentWorkspace.border = background;
          colors.urgentWorkspace.text = background;
          fonts = {
            names = [ config.font-name "Symbola"];
            style = "Condensed";
            size = config.font-size - 4.0;
          };
          position = "top";
          statusCommand = "${self.defaultPackage.x86_64-linux}/bin/swaybar";
        }];
      };

    defaultPackage.x86_64-linux =
      nixpkgs.legacyPackages.x86_64-linux.rustPlatform.buildRustPackage {
        pname = "swaybar";
        version = "0.1.0";

        src = ./.;

        cargoSha256 = "YiNaEyiKfiBIWzRXNIoqeWzoD/AGYNXYyy33Tj3a61g=";

        meta = with nixpkgs.lib; {
          description = "My personal code for swaybar";
          homepage = "https://sr.ht/rprospero/swaybar";
          license = licenses.unlicense;
          maintainers = [ maintainers.rprospero ];
        };
      };
  };
}
