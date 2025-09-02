{ pkgs, config, ... }:
{
  age.secrets = {
    "mealie-secrets".file = ../../secrets/mealie-secrets.age;
  };

  virtualisation.oci-containers.containers.mealie = {
    image = "ghcr.io/mealie-recipes/mealie:v3.1.2";
    autoStart = true;
    volumes = [
      "mealie-data:/app/data/"
    ];
    ports = [ "8030:9000" ];
    environment = {
      TZ = "America/Detroit";
      WEB_CONCURRENCY = "1";
      BASE_URL = "https://cook.h.tspi.io";
      LOG_LEVEL = "INFO";
    };
    environmentFiles = [ config.age.secrets."mealie-secrets".path ];
  };
}