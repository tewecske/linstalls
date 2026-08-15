{ config, lib, ... }:
let
  # Same out-of-store symlink trick as home/common.nix's Dotfiles section.
  repo = "${config.home.homeDirectory}/linstalls";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
{
  programs.tmux.enable = true;

  # programs.tmux always generates $XDG_CONFIG_HOME/tmux/tmux.conf from its
  # own structured options + extraConfig. tmux.conf here is hand-written
  # (plugins, catppuccin theming, custom binds) and meant to be edited live,
  # so force it back to the plain out-of-store symlink instead of translating
  # it into module options.
  xdg.configFile."tmux/tmux.conf" = lib.mkForce {
    source = link "tmux/tmux.conf";
  };
}
