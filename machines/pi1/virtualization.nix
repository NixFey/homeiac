{ pkgs, config, ... }: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";

  networking.firewall = {
    # Just temporary
    enable = false;
  };

  environment.systemPackages = with pkgs; [ podman-tui ];
}