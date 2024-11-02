{
  description = "Deploy home servers";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  outputs = { self, nixpkgs, agenix, deploy-rs } @ inputs : {
    nixosConfigurations = {
      pi1 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules =
          [
            ./machines/pi1/configuration.nix
            agenix.nixosModules.default
          ];
        specialArgs = { inputs = { agenix = inputs.agenix; }; };
      };
    };

    deploy.nodes.pi1 = {
      hostname = "pi1";
      profiles = {
        system = {
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pi1;
          sshUser = "op";
          user = "root";
          remoteBuild = true;
        };
      };
      remoteBuild = true;
    };

    #checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}