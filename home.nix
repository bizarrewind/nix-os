{ config, pkgs, inputs, ... }: {
  home.username = "vexil";
  home.homeDirectory = "/home/vexil";
  home.stateVersion = "26.05";

  # User packages managed via Home Manager (no full system rebuild needed!)
  home.packages = [
    # External flake packages
    inputs.claude-desktop.packages.${pkgs.system}.default
  ] ++ (with pkgs; [
    # Quick user utilities / editors
    ripgrep
    btop
    neovim
    eza
    zoxide
    starship
  ]);

  # Sleek, fast, beautiful prompt that integrates with any colorscheme
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      directory = {
        truncation_length = 4;
        style = "bold cyan";
      };
      git_branch = {
        style = "bold purple";
      };
      git_status = {
        style = "bold red";
      };
    };
  };

  # Smarter cd command
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    historySubstringSearch.enable = true;

    # Oh-My-Zsh integration with useful plugins
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "colored-man-pages"
        "extract"
      ];
    };

    shellAliases = {
      # Modern replacements with icons
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first";
      la = "eza -la --icons --group-directories-first";
      lt = "eza --tree --level=2 --icons";

      # Use zoxide for intelligent jumping seamlessly replacing cd
      cd = "z";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";

      # Fast user config rebuild (2-3 seconds, no sudo)
      home-switch = "home-manager switch --flake /home/vexil/.dotfiles/nixos#vexil";
      # Full system rebuild (hardware/services, requires sudo)
      nix-switch = "sudo nixos-rebuild switch --flake /home/vexil/.dotfiles/nixos#nixos";
    };
  };

  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font";
  };

  # Direct dotfile symlinks for desktop components
  xdg.configFile."hypr".source = ./hypr;
  xdg.configFile."waybar".source = ./waybar;

  # User-level stylix overrides to protect our handcrafted Waybar and Hyprlock aesthetics
  stylix.targets = {
    waybar.enable = false;
    hyprlock.enable = false;
  };

  programs.home-manager.enable = true;
}

