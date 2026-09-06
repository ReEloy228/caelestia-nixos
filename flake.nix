{
  description = "A caelestia-dots home-manager module.";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: let
    opts = import ./configs/caelestia/shell/options.nix { lib = inputs.nixpkgs.lib; };
  in {
    homeManagerModules.default = import ./caelestia.nix inputs;
    lib = {
      inherit (opts) mkEntry mkAction sessionCommands;
    };
  };
}
