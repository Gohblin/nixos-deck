# steamdeck-audio-fix.nix
{ config, pkgs, lib, ... }:

{
  # Core PipeWire configuration
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Steam Deck specific audio packages
  environment.systemPackages = with pkgs; [
    alsa-utils     # Basic ALSA utilities like amixer, alsamixer
    alsa-tools     # Additional ALSA tools
    pavucontrol    # PulseAudio volume control GUI
    pamixer        # Command line mixer for PulseAudio
    pulsemixer     # CLI and curses mixer for PulseAudio
    helvum         # GUI patch bay for PipeWire
  ];

  # Ensure firmware is available
  hardware.enableAllFirmware = true;

  # Add Steam Deck specific PipeWire optimizations
  environment.etc = {
    # Steam Deck audio optimization
    "pipewire/pipewire.conf.d/99-steamdeck-audio.conf" = {
      text = ''
        # Steam Deck audio optimizations
        context.properties = {
          # Standard studio-quality settings
          default.clock.rate = 48000
          default.clock.quantum = 1024
          default.clock.min-quantum = 32
          default.clock.max-quantum = 8192
          # Increased priority for audio processing
          core.daemon = true
          core.rt.priority = 88
        }
        
        context.modules = [
          # Ensure module-rt is loaded
          { name = libpipewire-module-rt
            args = {
              nice.level = -11
              rt.prio = 88
              rt.time.soft = -1
              rt.time.hard = -1
            }
            flags = [ ifexists nofail ]
          }
        ]
      '';
      mode = "0644";
    };
    
    # Add specific ALSA UCM (Use Case Manager) configuration if needed
    # "alsa/ucm2/AMD/steamdeck/AMD.conf" = {
    #   source = ./path/to/ucm/AMD.conf;
    # };
  };

  # Load audio-related kernel modules
  boot.extraModulePackages = [];
  boot.kernelModules = [ 
    "snd-seq" 
    "snd-seq-midi"
    # Add other specific modules if needed
  ];
  
  # Persistent storage for ALSA state
  environment.etc."alsa/state-daemon.conf".text = ''
    # ALSA state storage daemon
    persistence {
      directory "/var/lib/alsa"
      period 5
    }
  '';

  # Create a systemd service to fix audio on boot
  systemd.services.steamdeck-audio-fix = {
    description = "Fix Steam Deck audio initialization";
    wantedBy = [ "multi-user.target" ];
    after = [ "pipewire.service" ];
    path = [ pkgs.alsa-utils ];
    script = ''
      # Unmute and set volumes
      amixer -c 0 sset Master unmute
      amixer -c 0 sset Master 70%
      amixer -c 0 sset Speaker unmute
      amixer -c 0 sset Speaker 70%
      amixer -c 0 sset Headphone unmute
      amixer -c 0 sset Headphone 70%
      
      # Restore ALSA state if available
      if [ -f /var/lib/alsa/asound.state ]; then
        alsactl restore
      else
        # Store current state for future boots
        alsactl store
      fi
      
      # Restart PipeWire services if needed
      systemctl --user restart pipewire pipewire-pulse wireplumber || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
  };

  # Directory for storing ALSA state
  systemd.tmpfiles.rules = [
    "d /var/lib/alsa 0755 root root -"
  ];

  # Optional: Add udev rules if needed for Steam Deck audio hardware
  services.udev.extraRules = ''
    # Ensure Steam Deck audio devices get correct permissions
    SUBSYSTEM=="sound", ACTION=="add", ATTRS{idVendor}=="1022", TAG+="systemd", ENV{SYSTEMD_WANTS}+="steamdeck-audio-fix.service"
  '';
}
