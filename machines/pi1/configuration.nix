{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./virtualization.nix
    ./mealie.nix
    ../../modules/nix.nix
    ../../modules/raspberry-pi-3.nix
  ];

  config = {
    system.stateVersion = "24.11";

    age.secrets = {
      "pi1-op-password".file = ../../secrets/pi1/op-password.age;
      "pi1-healthchecks-url".file = ../../secrets/pi1/healthchecks-url.age;
      "ssid-info".file = ../../secrets/ssid-info.age;
    };

    networking = {
      hostName = "pi1";
      wireless = {
        enable = true;
        secretsFile = config.age.secrets."ssid-info".path;
        networks."mySSID".pskRaw = "ext:SSID_PSK";
        interfaces = [ "wlan0" ];
      };
    };

    environment.systemPackages = [ pkgs.vim inputs.agenix.packages."aarch64-linux".default pkgs.curl ];

    services.openssh.enable = true;

    users = {
      mutableUsers = false;
      users.op = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets."pi1-op-password".path;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBRA2Vt7mNUy77EzUmw63u7EE3hqOjoMTeLLbQR9YvMm"
        ];
      };
    };

    security.sudo.wheelNeedsPassword = false;

    hardware.enableRedistributableFirmware = true;

    systemd.timers."healthcheck" = {
      wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1m";
          OnUnitActiveSec = "1m";
          Unit = "healthcheck.service";
        };
    };

    systemd.services."healthcheck" = {
      script = ''
        set -eu
        ${pkgs.curl}/bin/curl "$(cat ${config.age.secrets."pi1-healthchecks-url".path})"
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}