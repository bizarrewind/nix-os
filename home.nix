{ config, pkgs, inputs, lib, ... }: 

let
  c = config.lib.stylix.colors.withHashtag;
  rgb = config.lib.stylix.colors;
  orbit = pkgs.callPackage ./pkgs/orbit.nix {};
in
{
  home.username = "vexil";
  home.homeDirectory = "/home/vexil";
  home.stateVersion = "26.05";

  # User packages managed via Home Manager (no full system rebuild needed!)
  home.packages = [
    # External flake packages
    orbit
  ] ++ (with pkgs; [
    # Quick user utilities / editors
    ripgrep
    btop
    neovim
    eza
    zoxide
    base16-schemes # preset color scheme groups
    
    # Neovim / Lazy.nvim build dependencies
    gcc
    gnumake
    tree-sitter
    nodejs_22
    unzip
    wget
    curl
    nil
  ]);

  # Dynamic Starship Prompt derived from wallpaper colors
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status $character";

      character = {
        success_symbol = "[➜](bold ${c.base0A})";
        error_symbol   = "[✗](bold ${c.base08})";
        vimcmd_symbol  = "[❮](bold ${c.base0D})";
      };

      directory = {
        style             = "bold ${c.base0A}";
        truncation_length = 3;
        truncate_to_repo  = true;
        read_only         = " 󰌾";
        read_only_style   = "${c.base08}";
        format            = "[$path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        style  = "bold ${c.base0D}";
        symbol = " ";
        format = "[on](italic ${c.base04}) [$symbol$branch]($style) ";
      };
      git_status = {
        style     = "bold ${c.base08}";
        format    = "([\$all_status \$ahead_behind]($style) )";
        conflicted = "󰞇";
        ahead      = "⇡\${count}";
        behind     = "⇣\${count}";
        diverged   = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked  = "?";
        stashed    = "\\$";
        modified   = "!";
        staged     = "+";
        renamed    = "»";
        deleted    = "✘";
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
    syntaxHighlighting = {
      enable = true;
      styles = {
        "command" = "fg=${c.base0A},bold";
        "builtin" = "fg=${c.base0A},bold";
        "alias" = "fg=${c.base09},bold";
        "function" = "fg=${c.base09}";
        "unknown-token" = "fg=${c.base08},bold";
        "reserved-word" = "fg=${c.base0D},bold";
        "path" = "fg=${c.base0D},underline";
        "globbing" = "fg=${c.base0A}";
        "single-quoted-argument" = "fg=${c.base04}";
        "double-quoted-argument" = "fg=${c.base04}";
        "dollar-quoted-argument" = "fg=${c.base09}";
        "commandseparator" = "fg=${c.base03}";
        "redirection" = "fg=${c.base09}";
        "assign" = "fg=${c.base0D}";
        "comment" = "fg=${c.base03},italic";
        "arg0" = "fg=${c.base0A},bold";
      };
    };
    enableCompletion = true;
    historySubstringSearch.enable = true;

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
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first";
      la = "eza -la --icons --group-directories-first";
      lt = "eza --tree --level=2 --icons";

      cd = "z";
      ".." = "cd ..";
      "..." = "cd ../..";

      home-switch = "home-manager switch --flake /home/vexil/.dotfiles/nixos#vexil";
      nix-switch = "sudo nixos-rebuild switch --flake /home/vexil/.dotfiles/nixos#nixos && home-manager switch --flake /home/vexil/.dotfiles/nixos#vexil";
    };

    # Dynamic wallpaper palette for ZSH & Eza
    initExtra = ''
      # ── eza colors (dynamic Stylix palette) ─────────────────────────────
      # di=dir(${c.base0A}), ln=symlink(${c.base0D}), ex=exec(${c.base08})
      export EZA_COLORS="di=38;2;${toString rgb.base0A-rgb-r};${toString rgb.base0A-rgb-g};${toString rgb.base0A-rgb-b}:ln=38;2;${toString rgb.base0D-rgb-r};${toString rgb.base0D-rgb-g};${toString rgb.base0D-rgb-b}:ex=38;2;${toString rgb.base08-rgb-r};${toString rgb.base08-rgb-g};${toString rgb.base08-rgb-b}:fi=0:*.tar=38;2;${toString rgb.base04-rgb-r};${toString rgb.base04-rgb-g};${toString rgb.base04-rgb-b}:*.gz=38;2;${toString rgb.base04-rgb-r};${toString rgb.base04-rgb-g};${toString rgb.base04-rgb-b}:*.zip=38;2;${toString rgb.base04-rgb-r};${toString rgb.base04-rgb-g};${toString rgb.base04-rgb-b}:*.nix=38;2;${toString rgb.base0D-rgb-r};${toString rgb.base0D-rgb-g};${toString rgb.base0D-rgb-b}:*.lua=38;2;${toString rgb.base0D-rgb-r};${toString rgb.base0D-rgb-g};${toString rgb.base0D-rgb-b}:*.py=38;2;${toString rgb.base0A-rgb-r};${toString rgb.base0A-rgb-g};${toString rgb.base0A-rgb-b}:*.rs=38;2;${toString rgb.base08-rgb-r};${toString rgb.base08-rgb-g};${toString rgb.base08-rgb-b}:*.js=38;2;${toString rgb.base0A-rgb-r};${toString rgb.base0A-rgb-g};${toString rgb.base0A-rgb-b}:*.ts=38;2;${toString rgb.base0D-rgb-r};${toString rgb.base0D-rgb-g};${toString rgb.base0D-rgb-b}:*.md=38;2;${toString rgb.base09-rgb-r};${toString rgb.base09-rgb-g};${toString rgb.base09-rgb-b}:da=38;2;${toString rgb.base04-rgb-r};${toString rgb.base04-rgb-g};${toString rgb.base04-rgb-b}:sn=38;2;${toString rgb.base04-rgb-r};${toString rgb.base04-rgb-g};${toString rgb.base04-rgb-b}"

      # ── ZSH autosuggestion color ────────────────────────────────────────
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${c.base03}"

      # ── Completion menu colors ──────────────────────────────────────────
      zstyle ':completion:*' list-colors "di=38;2;${toString rgb.base0A-rgb-r};${toString rgb.base0A-rgb-g};${toString rgb.base0A-rgb-b}:ln=38;2;${toString rgb.base0D-rgb-r};${toString rgb.base0D-rgb-g};${toString rgb.base0D-rgb-b}:ex=38;2;${toString rgb.base08-rgb-r};${toString rgb.base08-rgb-g};${toString rgb.base08-rgb-b}:fi=0"
      zstyle ':completion:*:descriptions' format $'\e[38;2;${toString rgb.base04-rgb-r};${toString rgb.base04-rgb-g};${toString rgb.base04-rgb-b}m── %d ──\e[0m'
      zstyle ':completion:*:corrections' format $'\e[38;2;${toString rgb.base08-rgb-r};${toString rgb.base08-rgb-g};${toString rgb.base08-rgb-b}m── %d (errors: %e) ──\e[0m'
      zstyle ':completion:*:messages' format $'\e[38;2;${toString rgb.base04-rgb-r};${toString rgb.base04-rgb-g};${toString rgb.base04-rgb-b}m── %d ──\e[0m'
      zstyle ':completion:*:warnings' format $'\e[38;2;${toString rgb.base08-rgb-r};${toString rgb.base08-rgb-g};${toString rgb.base08-rgb-b}m── no matches ──\e[0m'
    '';
  };

  programs.vscode.enable = true;
  programs.firefox.enable = true;

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      background_opacity = lib.mkForce "0.88";
      dynamic_background_opacity = "yes";
      window_padding_width = "10 14";

      cursor = "${c.base0A}";
      cursor_text_color = "${c.base00}";
      cursor_shape = "beam";
      cursor_beam_thickness = "1.5";
      cursor_blink_interval = "0.5";

      url_color = "${c.base0D}";
      url_style = "curly";

      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_min_tabs = "2";
      active_tab_foreground = "${c.base00}";
      active_tab_background = "${c.base0A}";
      active_tab_font_style = "bold";
      inactive_tab_foreground = "${c.base04}";
      inactive_tab_background = "${c.base01}";
      inactive_tab_font_style = "normal";
      tab_bar_background = "${c.base00}";

      selection_foreground = "${c.base05}";
      selection_background = "${c.base02}";

      enable_audio_bell = "no";
      visual_bell_duration = "0.1";
      visual_bell_color = "${c.base08}";

      scrollback_lines = "10000";
      confirm_os_window_close = "0";
    };
  };

  # ── Dynamically generated color definition files for Crystal UI Desktop ───
  xdg.configFile."dynamic-colors/waybar.css".text = ''
    @define-color fire_gold       ${c.base0A};
    @define-color fire_amber      ${c.base09};
    @define-color ember_orange    ${c.base08};
    @define-color ice_blue        ${c.base0D};
    @define-color smoke_grey      ${c.base04};
    @define-color ash_dark        rgba(${toString rgb.base01-rgb-r}, ${toString rgb.base01-rgb-g}, ${toString rgb.base01-rgb-b}, 0.85);
    @define-color ash_medium      rgba(${toString rgb.base02-rgb-r}, ${toString rgb.base02-rgb-g}, ${toString rgb.base02-rgb-b}, 0.70);
    @define-color glass_surface   rgba(255, 255, 255, 0.06);
    @define-color glass_specular  rgba(255, 255, 255, 0.42);
    @define-color glass_border    rgba(255, 255, 255, 0.18);
    @define-color text_bright     ${c.base05};
    @define-color text_muted      ${c.base04};
  '';

  xdg.configFile."dynamic-colors/swaync.css".text = ''
    @define-color fire_gold      ${c.base0A};
    @define-color fire_amber     ${c.base09};
    @define-color ember          ${c.base08};
    @define-color ice_blue       ${c.base0D};
    @define-color smoke          ${c.base04};
    @define-color bg_base        rgba(${toString rgb.base00-rgb-r}, ${toString rgb.base00-rgb-g}, ${toString rgb.base00-rgb-b}, 0.92);
    @define-color bg_card        rgba(${toString rgb.base01-rgb-r}, ${toString rgb.base01-rgb-g}, ${toString rgb.base01-rgb-b}, 0.88);
    @define-color bg_widget      rgba(${toString rgb.base02-rgb-r}, ${toString rgb.base02-rgb-g}, ${toString rgb.base02-rgb-b}, 0.65);
    @define-color glass_border   rgba(255, 255, 255, 0.14);
    @define-color specular       rgba(255, 255, 255, 0.35);
    @define-color text_bright    ${c.base05};
    @define-color text_muted     ${c.base04};
  '';

  xdg.configFile."dynamic-colors/eww.scss".text = ''
    $fire_gold:    ${c.base0A};
    $fire_amber:   ${c.base09};
    $ember:        ${c.base08};
    $ice_blue:     ${c.base0D};
    $smoke:        ${c.base04};
    $bg_base:      rgba(${toString rgb.base00-rgb-r}, ${toString rgb.base00-rgb-g}, ${toString rgb.base00-rgb-b}, 0.92);
    $bg_card:      rgba(${toString rgb.base01-rgb-r}, ${toString rgb.base01-rgb-g}, ${toString rgb.base01-rgb-b}, 0.45);
    $glass_border: rgba(255, 255, 255, 0.16);
    $specular:     rgba(255, 255, 255, 0.40);
    $text_bright:  ${c.base05};
    $text_muted:   ${c.base04};
  '';

  xdg.configFile."dynamic-colors/wlogout.css".text = ''
    @define-color fire_gold      ${c.base0A};
    @define-color fire_amber     ${c.base09};
    @define-color ember          ${c.base08};
    @define-color ice_blue       ${c.base0D};
    @define-color smoke          ${c.base04};
    @define-color bg_card        rgba(${toString rgb.base01-rgb-r}, ${toString rgb.base01-rgb-g}, ${toString rgb.base01-rgb-b}, 0.88);
    @define-color glass_border   rgba(255, 255, 255, 0.14);
    @define-color specular       rgba(255, 255, 255, 0.35);
    @define-color text_bright    ${c.base05};
  '';

  xdg.configFile."dynamic-colors/rofi.rasi".text = ''
    * {
        fire-gold:       ${c.base0A};
        fire-amber:      ${c.base09};
        ember-orange:    ${c.base08};
        ice-blue:        ${c.base0D};
        smoke-grey:      ${c.base04};
    }
  '';

  xdg.configFile."dynamic-colors/hyprlock.conf".text = ''
    $time_color = rgba(${toString rgb.base05-rgb-r}, ${toString rgb.base05-rgb-g}, ${toString rgb.base05-rgb-b}, 0.90)
    $text_color = rgba(${toString rgb.base05-rgb-r}, ${toString rgb.base05-rgb-g}, ${toString rgb.base05-rgb-b}, 0.85)
    $date_color = rgba(${toString rgb.base04-rgb-r}, ${toString rgb.base04-rgb-g}, ${toString rgb.base04-rgb-b}, 0.90)
    $accent_blue = rgba(${toString rgb.base0D-rgb-r}, ${toString rgb.base0D-rgb-g}, ${toString rgb.base0D-rgb-b}, 0.75)
    $inner_box  = rgba(${toString rgb.base01-rgb-r}, ${toString rgb.base01-rgb-g}, ${toString rgb.base01-rgb-b}, 0.85)
    $check_color = rgba(${toString rgb.base09-rgb-r}, ${toString rgb.base09-rgb-g}, ${toString rgb.base09-rgb-b}, 0.80)
    $fail_color  = rgba(${toString rgb.base08-rgb-r}, ${toString rgb.base08-rgb-g}, ${toString rgb.base08-rgb-b}, 0.80)
    $caps_color  = rgba(${toString rgb.base0A-rgb-r}, ${toString rgb.base0A-rgb-g}, ${toString rgb.base0A-rgb-b}, 0.80)
  '';

  xdg.configFile."dynamic-colors/hypr.lua".text = ''
    return {
      active_border_1 = "rgba(${rgb.base0A}ee)",
      active_border_2 = "rgba(${rgb.base09}ee)",
      inactive_border = "rgba(${rgb.base02}88)",
    }
  '';

  xdg.configFile."dynamic-colors/nvim-palette.lua".text = ''
    return {
      base00 = "${c.base00}",
      base01 = "${c.base01}",
      base02 = "${c.base02}",
      base03 = "${c.base03}",
      base04 = "${c.base04}",
      base05 = "${c.base05}",
      base06 = "${c.base06}",
      base07 = "${c.base07}",
      base08 = "${c.base08}",
      base09 = "${c.base09}",
      base0A = "${c.base0A}",
      base0B = "${c.base0B}",
      base0C = "${c.base0C}",
      base0D = "${c.base0D}",
      base0E = "${c.base0E}",
      base0F = "${c.base0F}",
      fire_gold   = "${c.base0A}",
      fire_amber  = "${c.base09}",
      ember       = "${c.base08}",
      ice_blue    = "${c.base0D}",
      smoke       = "${c.base04}",
      ash_dark    = "${c.base01}",
      ash_medium  = "${c.base02}",
      text_bright = "${c.base05}",
      text_muted  = "${c.base04}",
      bg_black    = "${c.base00}",
    }
  '';

  xdg.configFile."orbit/config.toml".text = ''
    position = "top-right"
    margin_top = 10
    margin_bottom = 10
    margin_left = 10
    margin_right = 14
    window_transition = "none"
    window_transition_duration = 0
    stack_transition = "slidehorizontal"
    stack_transition_duration = 200
  '';

  xdg.configFile."orbit/theme.toml".text = ''
    accent_primary = "${c.base0A}"
    accent_secondary = "${c.base09}"
    background = "${c.base00}"
    foreground = "${c.base05}"
    destructive = "${c.base08}"
    opacity = 0.45
  '';

  xdg.configFile."orbit/style.css".text = ''
    * {
      background: none;
      background-color: transparent;
      box-shadow: none;
      border: none;
    }
    window, window.background {
      background-color: transparent;
      background: none;
    }
    .orbit-panel, label {
      font-family: "JetBrainsMono Nerd Font", monospace;
    }
    .orbit-panel {
      background-color: rgba(18, 13, 8, 0.45);
      border: 1px solid rgba(255, 255, 255, 0.15);
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 
        inset 0 1px 0 rgba(255, 255, 255, 0.42),
        0 8px 40px 0 rgba(0, 0, 0, 0.80);
      margin: 4px;
    }
    .orbit-header {
      padding: 12px 16px 4px 16px;
    }
    .orbit-title {
      font-weight: 800;
      font-size: 16px;
      color: #f5f0e8;
      text-shadow: 0 1px 2px rgba(0, 0, 0, 0.6);
    }
    .orbit-tab-bar {
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
      margin: 0 16px 8px 16px;
      padding-bottom: 4px;
    }
    .orbit-tab {
      color: #b0bac4;
      border-radius: 12px;
      padding: 6px 12px;
      transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .orbit-tab:hover {
      background-color: rgba(255, 255, 255, 0.08);
      color: #ffffff;
    }
    .orbit-tab.active {
      background-color: rgba(255, 255, 255, 0.15);
      color: #ffffff;
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.3);
    }
  '';

  # Direct dotfile symlinks for desktop components
  xdg.configFile."hypr".source    = ./hypr;
  xdg.configFile."waybar".source  = ./waybar;
  xdg.configFile."rofi".source    = ./rofi;
  xdg.configFile."swaync".source  = ./swaync;
  xdg.configFile."wlogout".source = ./wlogout;
  xdg.configFile."nvim".source    = ./nvim;
  xdg.configFile."eww".source     = ./eww;

  # Stylix targets control
  stylix.targets = {
    waybar.enable = false; # using our custom Crystal UI styling with dynamic colors.css
    hyprlock.enable = false;
    firefox.profileNames = [ "default" ];
  };

  programs.home-manager.enable = true;
}
