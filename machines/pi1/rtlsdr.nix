# RTLSDR-Airband and the SMB server that exposes the recordings

{ pkgs, config, ... }:
let
  configFile = pkgs.writeText "airband-config.conf" ''
    localtime = true;
    devices:
    ({
      type = "rtlsdr";
      mode = "scan";
      index = 0;
      gain = 25;
      centerfreq = 120.0;
      correction = 48;
      channels:
      (
        {
          freqs = ( 939.15 );
          modulation = "nfm";
          lowpass = 3200;
          highpass = 100;
          outputs: (
            {
              type = "file";
              directory = "/conf/rtlsdr-airband/mp3";
              filename_template = "DPM";
              split_on_transmission = true;
              append = true;
              dated_subdirectories = true;
            }
          );
        }
      );
    }
    );
  '';
in {
  virtualisation.oci-containers.containers."rtlsdr-airband" = {
    image = "ghcr.io/charlie-foxtrot/rtlsdr-airband:latest";
    autoStart = true;
    volumes = [
      "/conf/rtlsdr-airband/mp3:/conf/rtlsdr-airband/mp3"
      "${configFile}:/app/rtl_airband.conf"
    ];
    environment = {
      TZ = "America/Detroit";
    };
    extraOptions = [
      "--network=host"
      "--device=/dev/bus/usb"
    ];
  };

  systemd.tmpfiles.settings."10-rtlsdr-airband" = {
    "/conf/rtlsdr-airband/mp3".d = {
      mode = "0755";
      user = "op";
      group = "users";
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "ASDF";
        "max protocol" = "SMB3";
        "server string" = "pi1";
        "netbios name" = "pi1";
        "security" = "user";
      };
      "mp3" = {
        "path" = "/conf/rtlsdr-airband/mp3";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "op";
        "force group" = "users";
      };
    };
  };
}