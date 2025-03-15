# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [
      # Include the hardware configuration
      ./hardware-configuration.nix
    ];

  # Enable flakes and nix-command
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    hostName = "steamdeck";
    networkmanager.enable = true;
  };

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable Plasma 6
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Enable CUPS to print documents
  services.printing.enable = false;

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Enable Steam Deck specific configurations
  jovian = {
    # Enable Steam Deck hardware support
    devices.steamdeck = {
      enable = true;
      # Enable all Steam Deck specific features
      enableControllerUdevRules = true;
      enableDefaultCmdlineConfig = true;
      enableDefaultStage1Modules = true;
      enableFwupdBiosUpdates = true;
      enableGyroDsuService = true;
      enableKernelPatches = true;
      enableOsFanControl = true;
      enablePerfControlUdevRules = true;
      enableSoundSupport = true;
      enableXorgRotation = true;
      autoUpdate = false; # Disable auto-updates as we're using NixOS
    };

    # Enable Steam with Steam Deck UI
    steam = {
      enable = true;
      autoStart = true;
      desktopSession = "plasma"; # Use Plasma as the desktop session for "Switch to Desktop"
      user = "deck"; # Steam will run as the 'deck' user
      environment = {
        # Add any Steam-specific environment variables here
        # Example: STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      };
    };

    # Enable Decky Loader
    decky-loader = {
      enable = true;
      user = "deck"; # Decky Loader will run as the 'deck' user
    };

    # Enable SteamOS-like configurations
    steamos = {
      enableAutoMountUdevRules = true;
      enableBluetoothConfig = true;
      enableDefaultCmdlineConfig = true;
      enableEarlyOOM = true;
      enableMesaPatches = true;
      enableProductSerialAccess = true;
      enableSysctlConfig = true;
      enableVendorRadv = true;
      enableZram = true;
      useSteamOSConfig = true;
    };

    # Hardware configuration
    hardware = {
      amd.gpu = {
        enableBacklightControl = true;
        enableEarlyModesetting = true;
      };
      has.amd.gpu = true;
    };
  };

  # Enable gamescope for better gaming performance
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Enable Steam (regular desktop version)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Define a user account
  users.users.deck = {
    isNormalUser = true;
    description = "Steam Deck User";
    extraGroups = [ "networkmanager" "wheel" "video" "input" "gamemode" ];
    packages = with pkgs; [
      firefox
      mangohud
      gamemode
      lutris
      protontricks
      winetricks
      protonup-qt
      bottles
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    pciutils
    usbutils
    htop
    btop
    neofetch
    glxinfo
    vulkan-tools
    mesa-demos
    xorg.xdpyinfo
    xorg.xev
    libva-utils
    powertop
    tlp
    gnome.gnome-disk-utility
    gparted
    ntfs3g
    exfat
    dosfstools
  ];

  # Enable power management
  powerManagement.enable = true;
  services.tlp.enable = true;

  # Enable gamemode for better gaming performance
  programs.gamemode.enable = true;

  # Enable fwupd for firmware updates
  services.fwupd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
