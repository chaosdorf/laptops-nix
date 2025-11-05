{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      ./common.nix
      (modulesPath + "/installer/scan/not-detected.nix")
    ];
  
  networking.hostName = "ws2"; # Define your hostname.
  boot.plymouth.theme = "cerealkiller";

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/43927392-0be3-4970-a070-df0346e2f420";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0336-0092";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];
  # This device has only 4GB RAM.
  zramSwap.enable = true;
  nix.settings.max-jobs = 1;
}
