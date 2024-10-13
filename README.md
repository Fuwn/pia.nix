# 🔒 `pia.nix`

> Private Internet Access VPN Configurations for NixOS

## Flake-based Installation

Add the `pia.nix` NixOS module to your system flake and configuration.

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.pia.url = "github:Fuwn/pia.nix";
  inputs.pia.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { nixpkgs, pia, self }: {
    nixosConfigurations.yourConfiguration = nixpkgs.lib.nixosSystem {
      modules = [ pia.nixosModules."x86_64-linux".default ];
    };
  };
}
```

## Module Set-up

Configure `pia.nix` in your NixOS configuration through the `services.pia`
attribute set.

```nix
{ config, ... }: {
  services.pia.enable = true;
  services.pia.authUserPass.username = "hooty";
  services.pia.authUserPass.password = "hunter42";
}
```

## Usage

```sh
# Activate VPN in a specific region
pia-start japan

# Deactivate VPN
pia-stop japan

# List all available VPN regions
pia-list

# List all available VPN regions with fuzzy search support
pia-search
```

## Credits

This repository started off as a fork of [~rprospero/nixos-pia](https://git.sr.ht/~rprospero/nixos-pia),
which provided a starting point for populating OpenVPN with Private Internet
Access' VPN configurations.
