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
      gain = 10;
      centerfreq = 120.0;
      correction = 48;
      channels:
      (
        {
          freqs = ( 939.15 );
          modulation = "nfm";
          // lowpass = 3200;
          // highpass = 100;
          outputs: (
            {
              type = "file";
              directory = "/conf/rtlsdr-airband/mp3";
              filename_template = "D";
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
    image = "ghcr.io/rtl-airband/rtlsdr-airband:v5.1.1";
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

  virtualisation.oci-containers.containers."audiobrowser" = {
    image = "ghcr.io/nixfey/audiobrowser:sha-cbbe397";
    autoStart = true;
    volumes = [
      "/conf/rtlsdr-airband/mp3:/files"
    ];
    environment = {
      FILES_BASE_PATH = "/files";
    };
    user = "root";
    ports = [ "8080:3000" ];
    extraOptions = [
      "--privileged"
    ];
  };
}
