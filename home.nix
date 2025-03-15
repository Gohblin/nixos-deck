{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "deck";
  home.homeDirectory = "/home/deck";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable Plasma 6 specific configurations
  programs.plasma = {
    enable = true;
    workspace = {
      clickItemTo = "select";
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
    };
    kwin = {
      titlebarButtons = {
        left = [ "on-all-desktops" "keep-above-windows" ];
        right = [ "minimize" "maximize" "close" ];
      };
      effects = {
        desktopGrid.enable = true;
        wobblyWindows.enable = true;
        magicLamp.enable = true;
      };
    };
    shortcuts = {
      kwin = {
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
      };
    };
  };

  # Configure git
  programs.git = {
    enable = true;
    userName = "Steam Deck User";
    userEmail = "deck@steamdeck.local";
  };

  # Configure bash
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake .#steamdeck";
      upgrade = "sudo nix flake update && sudo nixos-rebuild switch --flake .#steamdeck";
    };
    sessionVariables = {
      EDITOR = "vim";
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };
  };

  # Install user packages
  home.packages = with pkgs; [
    # Internet
    discord
    element-desktop
    
    # Gaming
    prismlauncher # Minecraft launcher
    heroic        # Epic Games, GOG, and Amazon Games launcher
    
    # Utilities
    flameshot     # Screenshot tool
    mpv           # Media player
    vlc           # Media player
    libreoffice   # Office suite
    
    # Development
    vscode
    
    # Themes
    papirus-icon-theme
    
    # System tools
    libnotify
    xdg-utils
  ];

  # Configure dconf settings for GNOME/GTK applications
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-animations = true;
      font-antialiasing = "rgba";
      font-hinting = "slight";
    };
  };

  # Configure GTK
  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.breeze-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Breeze";
      package = pkgs.breeze-icons;
      size = 24;
    };
  };

  # Configure Qt
  qt = {
    enable = true;
    platformTheme = "kde";
    style = {
      name = "breeze";
      package = pkgs.breeze-qt5;
    };
  };

  # Configure default applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "application/pdf" = [ "org.kde.okular.desktop" ];
      "image/png" = [ "org.kde.gwenview.desktop" ];
      "image/jpeg" = [ "org.kde.gwenview.desktop" ];
    };
  };

  # Enable services
  services = {
    # Sync time
    syncthing.enable = true;
    
    # Notification daemon
    dunst.enable = true;
    
    # Automatic screen color temperature adjustment
    redshift = {
      enable = true;
      temperature = {
        day = 6500;
        night = 3700;
      };
    };
  };
}
