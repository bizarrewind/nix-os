# Configure Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    
    # Link your user configurations here
    users.yourusername = { pkgs, ... }: {
      home.stateVersion = "26.05"; # Match your current system version

      # Native apps managed by Home Manager
      programs.zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        autosuggestions.enable = true;
      };

      programs.kitty = {
        enable = true;
        font.name = "JetBrainsMono Nerd Font";
      };

      # Automatically symlink raw config files (like Hyprland) into ~/.config/
      xdg.configFile."hypr".source = ./hypr; # Assumes a 'hypr' folder exists in your repo
    };
  };
