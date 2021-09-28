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

  # Command to edit this system configuration in VSCode as root
  edit-system-configuration = pkgs.writeShellScriptBin "edit-system-configuration" ''
    code /etc/nixos --user-data-dir
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Allow Automatic Upgrades
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    # channel = https://nixos.org/channels/nixos-unstable; # Use the unstable channel
    channel = https://nixos.org/channels/nixos-21.05; # Use the stable channel
  };

  # Configure the package manager
  nix = {
    # Enable Garbage Collection every day at 8am
    gc = {
      automatic = true;
      dates = "08:00";
    };

    # Enable a binary cache
    binaryCachePublicKeys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];

    binaryCaches = [
      "https://hydra.iohk.io"
    ];
  };

  # Allow Propietary Software
  nixpkgs.config.allowUnfree = true;

  # Additional hardware configuration
  hardware = {
    # Enable sound
    pulseaudio.enable = true;

    # Enable Bluetooth Headsets
    pulseaudio.package = pkgs.pulseaudioFull; # support for bluetooth headsets
    bluetooth.enable = true;

    # Enable OpenGL
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    # Enable the Nvidia graphics card
    nvidia = {
      modesetting.enable = true;
      nvidiaPersistenced = true;

      powerManagement = {
        enable = true;
        finegrained = true;
      };

      prime = {
        offload.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };

  # Configure the boot process
  boot = {
    # Clean /tmp each boot
    cleanTmpDir = true;

    # Configure the bootloader
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;

      # Allow the bootloader to use EFI
      efi.canTouchEfiVariables = true;

      # Configure GRUB
      grub = {
        enable = true;
        version = 2;
        devices = ["nodev"];
        efiSupport = true;
        fontSize = 16;

        # Use a scaled down resolution
        gfxmodeEfi = "1024x768";

        # Use the nix theme
        theme = pkgs.nixos-grub2-theme;
        splashMode = "normal";

        # Enable encrypted disks
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
    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Configure keymap 
    layout = "us";

    # Enable touchpad support
    libinput.enable = true;

    # Enable the proprietary Nvidia driver
    videoDrivers = [ "nvidia" ];

    # Use the Gnome Display Manager
    displayManager.gdm = {
      enable = true;
      wayland = true;

      # Use the Nvidia card with GDM
      nvidiaWayland = true;

      # Automatically suspend when inactive
      autoSuspend = true;
    };

    # Enable the GNOME Desktop Environment.
    desktopManager.gnome = {
      enable = true;

      # Override Gnome Default Settings
      extraGSettingsOverrides = ''
        # Change default background
        [org.gnome.desktop.background]
        picture-uri='https://w.wallhaven.cc/full/od/wallhaven-odp737.jpg'

        [org.gnome.desktop.interface]
        # Use a 12 hour clock
        clock-format='12h'
    
        # Set the default theme
        gtk-theme='Orchis-purple-dark'
        icon-theme='Moka'
        cursor-theme='capitaine-cursors'


      '';
      extraGSettingsOverridePackages = [ pkgs.gsettings-desktop-schemas ];
    };
  };

  programs.fish.enable = true;

  # Enable Networking
  networking = {
    hostName = "prec5530-nixos";
    networkmanager.enable = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.wlp59s0.useDHCP = true;
  };

  # Set the time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;

  # Install extra fonts
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # Add my user
  users.users.jenr = {
    isNormalUser = true;
    description = "Jen Reiss";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = "$6$0cBK71aGreCGziV$9xEyPp4JkPE/Lsfo7GoRWSYL2TnRU3d8nQyVDObAkSpJI4nnjeIoLZaAq1IXjMGv/aHGLabcx1wDnja97cV4N/";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # User Applications
    google-chrome spotify gimp gparted zoom-us rpi-imager
    # System Utilities
    htop curl tree edit-system-configuration pciutils
    # Programming Tools
    vscode autoconf gnumake git gcc
    # Shells
    fish starship
    # Gnome Customization
    gnome.gnome-tweaks gnome.dconf-editor
    gnomeExtensions.openweather gnomeExtensions.user-themes
    # Theming
    orchis moka-icon-theme capitaine-cursors
    # Graphics Card
    nvidia-offload
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

