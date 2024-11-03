{ pkgs, config, ... }:
{
  age.secrets = {
    "mealie-secrets".file = ../../secrets/mealie-secrets.age;
  };

  virtualisation.oci-containers.containers.mealie = {
    image = "ghcr.io/mealie-recipes/mealie:v2.1.0";
    autoStart = true;
    volumes = [
      "mealie-data:/app/data/"
    ];
    ports = [ "8030:9000" ];
    environment = {
      TZ = "America/Detroit";
      WEB_CONCURRENCY = "1";
      BASE_URL = "https://cook.h.tspi.io";
    };
    environmentFiles = [ config.age.secrets."mealie-secrets".path ];
  };
}