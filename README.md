# Nixos Module for PIA

The repo contains a flake module to add the Private Internet Access
VPNs to your Nixos system.

## Installation

You'll need to include this module in your `flake.nix` file:

```
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.pia.url = "github:Fuwn/nixos-pia?ref=development";
  inputs.pia.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, pia }: {
	nixosConfigurations.owlhouse = nixpkgs.lib.nixosSystem {
	  system = "x86_64-linux";
	  modules = [
		pia.nixosModule
		./config.nix
	  ];
	};
```

And you'll need to enable the vpn in another module.  For example, you might have the following in your `config.nix`

```
{ config, ...}:
{
  services.pia.enable = true;
  services.pia.authUserPass.username = "hooty";
  services.pia.authUserPass.password = "hunter42";
}
```
