{ pkgs, config, ... }: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    nginx-sample = {
      image = "nginxdemos/hello";
      autoStart = true;
      ports = [ "8020:80" ];
    };
    home-assistant = {
      image = "ghcr.io/home-assistant/home-assistant:2024.10.4";
      autoStart = true;
      volumes = [ "/conf/homeassistant/config:/config" ];
      extraOptions = [
        "--network=host"
        "--privileged"
        "-e TZ=America/Detroit"
        # "-v /run/dbus:/run/dbus:ro" # Required only if using bluetooth
      ];
    };
  };

  systemd.services."${config.virtualisation.oci-containers.backend}-home-assistant-volumes" = {
    script = ''
      mkdir -p /conf/homeassistant/config || true;
    '';
    before = ["${config.virtualisation.oci-containers.backend}-home-assistant.service"];
    wantedBy = ["${config.virtualisation.oci-containers.backend}-home-assistant.service"];
  };

  networking.firewall = {
    # Just temporary
    enable = false;
  };

  environment.systemPackages = with pkgs; [ podman-tui ];
}