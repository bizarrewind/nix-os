{ config, pkgs, lib, ... }:

let
  userConfig = if builtins.pathExists ./user-config.nix
    then import ./user-config.nix
    else { username = "nixosuser"; enableKeyd = false; };
  currentUsername = userConfig.username or "nixosuser";
  enableKeyd = userConfig.enableKeyd or false;
in
{
  # Include other configuration files (hardware details, packages, theming)
  imports = [
    ./hardware-configuration.nix
    ./pkgs.nix
    ./coding.nix
    ./stylix.nix
  ];
  # Enable gnome-keyring to save authentication secrets
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  services.logind.settings.Login.HandlePowerKey = "lock"; 

  # Power Management & Low Battery Protection
  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
    percentageLow = 20;
    percentageCritical = 10;
    percentageAction = 4;
  }; 

  virtualisation.docker.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs;[
    stdenv.cc.cc #provides libstdc++.so.6
    zlib 
    ];


  # Setup Intel graphics hardware acceleration for better video performance
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver      # Video decoding/encoding driver
      vpl-gpu-rt              # Quick Sync Video runtime
      intel-compute-runtime   # OpenCL support for compute tasks
    ];
  };

  # Force apps to use the modern Intel video driver
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Bootloader configuration (Systemd-boot with EFI support)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network and system name settings
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Timezone and regional locale settings (India)
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable experimental Nix features like flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure keyboard remapping (Caps Lock acts as Ctrl/Escape)
  services.keyd = {
    enable = enableKeyd;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(control,esc)";
            leftcontrol = "overload(control,capslock)";
          };
          otherlayer = {};
        };
        extraConfig = "";
      };
    };
  };

  # Display and Bluetooth hardware settings
  services.xserver.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable KDE Plasma desktop environment and login screen
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  
  programs.hyprland.enable = true;

  # Keyboard layout settings
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable printing services
  services.printing.enable = true;

  # Enable Pipewire for audio management (disables old PulseAudio)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define the main user account and their personal apps
  users.users.${currentUsername} = {
    isNormalUser = true;
    description = currentUsername;
    initialPassword = "nixos"; # Default password for fresh installations
    extraGroups = [ "networkmanager" "wheel" "docker"]; # Gives admin (sudo) access
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Enable system-level zsh configuration
  programs.zsh.enable = true;

  # Enable web browser and allow installation of proprietary packages
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Basic system-wide tools installed for everyone
  environment.systemPackages = with pkgs; [
    google-chrome
    vim
    wget
    home-manager
    gnome-keyring
  ];

  # NixOS version compatibility flag (keep at the version you installed)
  system.stateVersion = "26.05";
}
