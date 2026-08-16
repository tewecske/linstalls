
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

alias vim='nvim'
alias vimdiff='nvim -d'
alias nvimdiff='nvim -d'
alias ws='cd "$HOME/projects/"'

# GL apps (libGDX/LWJGL, e.g. boxdefense) can't find the host's OpenGL libs:
# nix's loader never searches /usr/lib/x86_64-linux-gnu, so plain `sbt run`
# fails with "GLX: Failed to load GLX". nixGLIntel (nixpkgs mesa, software GL)
# wraps the command. See home/common.nix.
alias sbt='nixGLIntel sbt'

# home-manager: the config lives in a flake, not at the default
# ~/.config/home-manager/home.nix, so every subcommand needs --flake.
#   hm switch     hm news     hm build
# HM_TARGET is set per machine in linstalls/home/<host>.nix.
hm() {
  if [ -z "$HM_TARGET" ]; then
    echo "hm: HM_TARGET unset - run once explicitly:" >&2
    echo "  home-manager switch -b backup --flake ~/linstalls#tewe@<host>" >&2
    return 1
  fi
  local cmd="$1"; shift
  case "$cmd" in
    generations|expire-generations|uninstall|packages)
      home-manager "$cmd" "$@" ;;              # these take no flake
    *)
      home-manager "$cmd" --flake "$HOME/linstalls#$HM_TARGET" "$@" ;;
  esac
}

