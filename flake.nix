{
  description = "nixos-hyprland";
  ################################################
  # Inputs
  ################################################
  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Neovim
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    # Claude Code Updated Every Hour
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Claude Desktop
    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian/v2.0.13+claude1.8555.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Walker + Elephant (App Launcher)
    elephant = {
      url = "github:abenz1267/elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };
  };
  ################################################
  # Outputs
  ################################################
  outputs = { nixpkgs, home-manager, ... } @ inputs:
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ################################################
        # Custom Overlays
        ################################################
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            inputs.claude-desktop.overlays.default
            (final: prev: {
              walker = inputs.walker.packages.${prev.system}.default;
              elephant = inputs.elephant.packages.${prev.system}.default;
            })
          ];
          environment.systemPackages = [ 
            pkgs.claude-desktop-fhs 
          ];
        })
        ################################################
        # Home Manager
        ################################################
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.alex = import ./home.nix;
          home-manager.sharedModules = [
            inputs.nixvim.homeModules.nixvim
          ];
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
