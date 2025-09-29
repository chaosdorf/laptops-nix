# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.gtk.enable = false;
    greeters.slick.enable = true;
    extraConfig = ''
      guest-account-script=${pkgs.lightdm-guest-account}/bin/guest-account
    '';
    extraSeatDefaults = ''
      greeter-hide-users=true
      greeter-show-manual-login=true
    '';
  };

  # Enable desktop environments
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.flatpak.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Install shells
  programs.zsh.enable = true;
  programs.fish.enable = true;
  
  # Install browsers
  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.thunderbird.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # editors
    vim
    thonny
    vscode
    zed-editor
    jetbrains.pycharm-community-bin
    
    # command line tools
    wget
    git
    python3Full
    
    # desktop applications
    vlc
    libreoffice-qt6
    
    # system stuff
    kdePackages.discover
    kdePackages.isoimagewriter
    kdePackages.plasma-welcome
    lightdm-guest-account
    gettext # needed for guest-account
  ];

  # List services that you want to enable:
  services.homed.enable = true;
  system.activationScripts.binbash = ''
    ln -sfn /run/current-system/sw/bin/bash /bin/bash
    mkdir -p /etc/skel
  '';

  # Add or modify packages
  nixpkgs.overlays = [
    (final: prev: rec {
      # Add guest-mode to lightdm
      lightdm-guest-account = prev.stdenv.mkDerivation rec {
        pname = "lightdm-guest-account";
        version = src.rev;
        src = prev.fetchgit {
          url = "https://aur.archlinux.org/lightdm-guest-account.git";
          hash = "sha256-Ks2oGYfqbxgqKdbiIgiIkjI0yL8CZlp8yd7IHxilxnk=";
        };
        patches = [
          ./guest-account-path.patch
        ];
        installPhase = ''
          mkdir -p $out/bin
          install --mode +x guest-account.sh $out/bin/guest-account
        '';
      };
    })
  ];

  # This is needed for guest-session.
  users.groups.autologin = {};
  # allow the guest account to login
  # This is taken from nixpkgs/nixos/modules/services/x11/display-managers/lightdm.nix,
  # but without the uid >= 1000 check.
  security.pam.services.lightdm-autologin.text = lib.mkForce ''
        auth      requisite     pam_nologin.so
  
        auth      required      pam_permit.so
  
        account   sufficient    pam_unix.so
  
        password  requisite     pam_unix.so nullok yescrypt
  
        session   optional      pam_keyinit.so revoke
        session   include       login
  '';
  
  # add a local admin user
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
