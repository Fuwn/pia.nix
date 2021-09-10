# Nixos Module for PIA

The repo contains a flake module to add the Private Internet Access
VPNs to your Nixos system.

## Dislcaimer

I'm not associated with PIA in any way.  Depending on when you read
this, I may not even be a subscriber with them any longer.  However, I
thought it might be useful for other people who are.  I also vainly
hoped that it might inspire people to release Nixos modules for other
services.

## Installation

You'll need to include this module in your `flake.nix` file:

```
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.pia.url = "path:/home/adam/Code/nixos-pia";
  inputs.pia.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, pia }: {
	nixosConfigurations.mcp = nixpkgs.lib.nixosSystem {
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
  services.pia.authUserPass.username = "tron";
  services.pia.authUserPass.password = "hunter42";
}
```
