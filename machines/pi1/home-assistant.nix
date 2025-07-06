{ pkgs, config, ... }: {
  virtualisation.oci-containers.containers.home-assistant = {
    image = "ghcr.io/home-assistant/home-assistant:2025.7.1";
    autoStart = true;
    volumes = [ "/conf/homeassistant/config:/config" ];
    extraOptions = [
      "--network=host"
      "--privileged"
      "-e TZ=America/Detroit"
      # "-v /run/dbus:/run/dbus:ro" # Required only if using bluetooth
    ];
  };
  
  systemd.tmpfiles.settings."10-homeassistant" = {
    "/conf/homeassistant/config".d = {
      mode = "0700";
    };
  };
}