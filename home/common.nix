{ pkgs, lib, config, system, opencode, ... }:

let
  # Absolute path to this repo as checked out on the machine.
  # Dotfiles are symlinked *out of* the nix store so you can edit them
  # in place and see the change immediately, with no `home-manager switch`.
  repo = "${config.home.homeDirectory}/linstalls";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
{
  imports = [
    ./programs/home-manager.nix
    ./programs/bash.nix
    ./programs/git.nix
    ./programs/tmux.nix
    ./programs/fzf.nix
    ./programs/starship.nix
    ./programs/dircolors.nix
    ./programs/zoxide.nix
  ];

  home.username = "tewe";
  home.homeDirectory = lib.mkDefault "/home/tewe";

  # Do not bump casually: it pins state-migration behaviour, not package versions.
  home.stateVersion = "25.05";

  #############################################################################
  # Packages
  #############################################################################
  home.packages = with pkgs; [
    # --- basic dev ------------------------------------------------------------
    # git and tmux come from programs.git / programs.tmux (home/programs/)
    curl
    wget
    unzip
    zip
    gnumake
    gcc
    python3 # treesitter parser build dep
    ffmpeg
    nerd-fonts.meslo-lg

    # --- cli ------------------------------------------------------------------
    bat
    ripgrep
    jq
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
    delve # go debugger, driven by nvim-dap-go

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

    # --- editor tooling (replaces mason.nvim) ---------------------------------
    # Language servers for languages that have no toolchain section above, plus
    # the formatters nvim shells out to. gopls / metals / rust-analyzer / nil
    # live with their toolchains.
    lua-language-server
    vscode-langservers-extracted # html, css, json, eslint servers
    tailwindcss-language-server
    emmet-language-server
    htmx-lsp
    stylua # lua formatter; lua_ls does not format
    tree-sitter # nvim-treesitter's `main` branch shells out to it to build parsers

    # --- ai --------------------------------------------------------------------
    opencode.packages.${system}.opencode

    # --- opt-in: uncomment if you actually need these -------------------------
    # sqlite         # you said probably not needed
    # tailwindcss    # you said no separate executable needed
    # ocaml opam     # .profile still has a guarded opam init block
  ];

  #############################################################################
  # Dotfiles -> out-of-store symlinks into ~/linstalls
  #############################################################################
  home.file = {
    ".bash_aliases".source = link "bash/.bash_aliases";
    "bin/scripts".source = link "scripts";
  };

  # NOTE: ~/.config/nvim is deliberately NOT managed here. It is its own git
  # repo, and nvim's built-in plugin manager (`:h vim.pack`) writes
  # nvim-pack-lock.json into it. See README.md for the clone step.
  #
  # Language servers are NOT installed by nvim — Mason was removed. Every server
  # nvim enables must be on PATH from the list above.

  #############################################################################
  # Session
  #############################################################################
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "ghostty";
  };
}
