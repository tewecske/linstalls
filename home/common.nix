{ pkgs, lib, config, ... }:

let
  # Absolute path to this repo as checked out on the machine.
  # Dotfiles are symlinked *out of* the nix store so you can edit them
  # in place and see the change immediately, with no `home-manager switch`.
  repo = "${config.home.homeDirectory}/linstalls";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
{
  home.username = "tewe";
  home.homeDirectory = lib.mkDefault "/home/tewe";

  # Do not bump casually: it pins state-migration behaviour, not package versions.
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  #############################################################################
  # Packages
  #############################################################################
  home.packages = with pkgs; [
    # --- basic dev ------------------------------------------------------------
    git
    curl
    wget
    unzip
    zip
    gnumake
    gcc
    python3 # mason + treesitter build deps
    ffmpeg
    docker

    # --- cli ------------------------------------------------------------------
    bat
    ripgrep
    jq
    fzf
    starship
    tmux
    neovim

    # --- jvm / scala  (replaces sdkman + `cs setup`) ---------------------------
    jdk21
    scala_3
    sbt
    mill
    metals
    coursier # kept: nvim-metals shells out to `cs` for :MetalsInstall

    # --- go  (replaces `go install ...` + hand-rolled ~/bin symlinks) ----------
    go
    gopls
    air
    templ

    # --- node  (replaces fnm) -------------------------------------------------
    nodejs_22
    pnpm

    # --- rust  (was rustup in linstalls.log) ----------------------------------
    rustc
    cargo
    rust-analyzer

    # --- nix itself -----------------------------------------------------------
    nil # nix LSP
    nixfmt-rfc-style

    # --- opt-in: uncomment if you actually need these -------------------------
    # sqlite         # you said probably not needed
    # tailwindcss    # you said no separate executable needed
    # ocaml opam     # .profile still has a guarded opam init block
  ];

  #############################################################################
  # Dotfiles -> out-of-store symlinks into ~/linstalls
  #############################################################################
  home.file = {
    ".bashrc".source = link "bash/.bashrc";
    ".profile".source = link "bash/.profile";
    ".bash_aliases".source = link "bash/.bash_aliases";
    ".gitconfig".source = link "git/.gitconfig";
    "bin/scripts".source = link "scripts";
  };

  xdg.configFile = {
    "tmux/tmux.conf".source = link "tmux/tmux.conf";
    "tmux/tmux.reset.conf".source = link "tmux/tmux.reset.conf";
  };

  # NOTE: ~/.config/nvim is deliberately NOT managed here. It is its own git
  # repo (tewecske/kickstart.nvim) and lazy.nvim writes lazy-lock.json into it.
  # See README.md for the clone step.

  #############################################################################
  # Session
  #############################################################################
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  #############################################################################
  # tpm — tmux.conf `run`s it, and nix does not clone it.
  #
  # tpm derives TMUX_PLUGIN_MANAGER_PATH from the location of tmux.conf, so with
  # the config at ~/.config/tmux/tmux.conf everything lands in
  # ~/.config/tmux/plugins/. tmux.conf loads tpm from that same directory, so
  # this bootstrap clone is the only one. Remaining plugins: prefix + I in tmux.
  #############################################################################
  home.activation.installTpm = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${config.xdg.configHome}/tmux/plugins/tpm" ]; then
      run ${pkgs.git}/bin/git clone --depth 1 \
        https://github.com/tmux-plugins/tpm \
        "${config.xdg.configHome}/tmux/plugins/tpm"
    fi
  '';
}
