# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  # Command to run a program with the Nvidia GPU
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export MESA_GL_VERSION_OVERRIDE=4.3
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';

  # Command to edit this system configuration in VSCode
  edit-configuration = pkgs.writeShellScriptBin "edit-configuration" ''
    code /etc/nixos --user-data-dir
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Allow Automatic Upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.channel = https://nixos.org/channels/nixos-21.05;

  # Enable Garbage Collection every day at 8am
  nix.gc = {
    automatic = true;
    dates = "08:00";
  };

  # Allow Propietary Software
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = ["nodev"];
    efiSupport = true;
    fontSize = 16;
    gfxmodeEfi = "1024x768";
    theme = pkgs.nixos-grub2-theme;
    splashMode = "normal";
    enableCryptodisk = true;
    extraEntries = ''
    menuentry "Reboot" {
      reboot
    }
    menuentry "Poweroff" {
      halt
    }
    '';
  };

  # Enable Bluetooth Headsets
  hardware.pulseaudio.package = pkgs.pulseaudioFull; # support for bluetooth headsets
  hardware.bluetooth.enable = true;

  # Enable the proprietary Nvidia driver
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      offload.enable = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  # Enable Networking
  networking.hostName = "prec5530-nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set the time zone.
  time.timeZone = "America/Chicago";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp59s0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Use the Gnome Display Manager with Wayland
  services.xserver.displayManager.gdm = {
    enable = true;
    nvidiaWayland = true;
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      # Change default background
      [org.gnome.desktop.background]
      picture-uri='https://w.wallhaven.cc/full/od/wallhaven-odp737.jpg'
    '';
    extraGSettingsOverridePackages = [
      pkgs.gsettings-desktop-schemas # for org.gnome.desktop
      pkgs.gnome.gnome-shell # for org.gnome.shell
    ];
  };

  # Configure keymap in X11
  services.xserver.layout = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Install extra fonts
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # Add my user
  users.users.jenr = {
    isNormalUser = true;
    description = "Jen Reiss";
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = "$6$0cBK71aGreCGziV$9xEyPp4JkPE/Lsfo7GoRWSYL2TnRU3d8nQyVDObAkSpJI4nnjeIoLZaAq1IXjMGv/aHGLabcx1wDnja97cV4N/";
  };

  nix.binaryCachePublicKeys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  ];

  nix.binaryCaches = [
    "https://hydra.iohk.io"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    google-chrome
    spotify
    vscode
    htop
    autoconf
    gnumake
    curl
    git
    gcc
    gnumake
    gparted
    gimp
    tree
    nvidia-offload
    edit-configuration
    rpi-imager
    zoom-us
    starship
    pciutils
    gnome.gnome-tweaks
    gnomeExtensions.openweather
    gnomeExtensions.user-themes
    xorg.libXxf86vm
    orchis
    moka-icon-theme
    capitaine-cursors
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}

