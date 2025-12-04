{
  description = "Peter's Maintenance Scripts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # List of supported systems:
      supportedSystems = nixpkgs.lib.platforms.unix;

      # Function to generate a set based on supported systems:
      each = f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          let pkgs = import nixpkgs { inherit system; };
          in f pkgs system);
    in
    {
      packages = each (pkgs: system: {
        default = self.packages.${system}.maintenance-scripts;
        maintenance-scripts = pkgs.callPackage ./. { };
      });

      overlays.default = final: prev: {
        pjones = (prev.pjones or { }) // {
          maintenance-scripts = self.packages.${prev.stdenv.hostPlatform.system}.maintenance-scripts;
        };
      };
    };
}
