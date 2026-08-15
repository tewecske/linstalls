{
  description = "tewe dev environment (home-manager, standalone)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode = {
      url = "github:anomalyco/opencode/v1.18.18";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, opencode, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Every host = common.nix + one host file.
      mkHome =
        hostModule:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit system opencode;
          };
          modules = [
            ./home/common.nix
            hostModule
          ];
        };
    in
    {
      homeConfigurations = {
        "tewe@wsl" = mkHome ./home/wsl.nix;
        "tewe@ubuntu" = mkHome ./home/ubuntu.nix;
        "tewe@fedora" = mkHome ./home/fedora.nix;
        "tewe@nixos" = mkHome ./home/nixos.nix;
      };

      # So `nix run .#home-manager -- switch --flake .#tewe@wsl` works
      # without home-manager being installed first.
      packages.${system}.home-manager = home-manager.packages.${system}.home-manager;

      # `nix fmt`
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
