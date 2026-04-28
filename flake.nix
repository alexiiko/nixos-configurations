{
	description = "nixos-hyprland";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nixvim = {
			url = "github:nix-community/nixvim";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = {nixpkgs, home-manager, ...} @inputs: {
		nixosConfigurations.nixos = nixpkgs.lib.nixosSystem{
			system = "x86_64-linux";
			specialArgs = { inherit inputs; };
			modules = [
				./configuration.nix
				./hardware-configuration.nix

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
