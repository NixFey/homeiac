{ pkgs, config, ... }: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  age.secrets = {
    # "tandoor-secrets".file = ../../secrets/tandoor-secrets.age;
  };

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    nginx-sample = {
      image = "nginxdemos/hello";
      autoStart = true;
      ports = [ "8020:80" ];
    };
    home-assistant = {
      image = "ghcr.io/home-assistant/home-assistant:2024.11.2";
      autoStart = true;
      volumes = [ "/conf/homeassistant/config:/config" ];
      extraOptions = [
        "--network=host"
        "--privileged"
        "-e TZ=America/Detroit"
        # "-v /run/dbus:/run/dbus:ro" # Required only if using bluetooth
      ];
    };
    # tandoor = {
    #   image = "vabene1111/recipes";
    #   autoStart = true;
    #   volumes = [
    #     "tandoor-static:/opt/recipes/staticfiles"
    #     "tandoor-media:/opt/recipes/mediafiles"
    #   ];
    #   ports = [ "8030:8080" ];
    #   environment = {
    #     # SECRET_KEY Filled by tandoor-secrets
    #     DB_ENGINE = "django.db.backends.sqlite3";
    #     REMOTE_USER_AUTH = "1";
    #     TZ = "America/Detroit";
    #   };
    #   environmentFiles = [ config.age.secrets."tandoor-secrets".path ];
    # };
  };

  systemd.tmpfiles.settings."10-homeassistant" = {
    "/conf/homeassistant/config".d = {
      mode = "0700";
    };
  };

  networking.firewall = {
    # Just temporary
    enable = false;
  };

  environment.systemPackages = with pkgs; [ podman-tui ];
}