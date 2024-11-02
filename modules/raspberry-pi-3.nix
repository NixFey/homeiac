{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    # "/conf" = {
    #   device = "/dev/disk/by-label/NIXOS_SD";
    #   fsType = "ext4";
    #   options = [ "noatime" ];
    # };
  };

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 2 * 1024; # 2GB
  }];
}