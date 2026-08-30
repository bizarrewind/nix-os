{ config, pkgs, ... }: {
  home.username = "vexil";
  home.homeDirectory = "/home/vexil";
  home.stateVersion = "26.05";

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion= true;
  };

  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font";
  };

  xdg.configFile."hypr".source = ./hypr;

  programs.home-manager.enable = true;
}
