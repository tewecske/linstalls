# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# interactive-shell guard, history settings (HISTCONTROL/HISTIGNORE/HISTSIZE/
# HISTFILESIZE), histappend and checkwinsize are all set via
# programs.bash.* in home/programs/bash.nix; not needed here.

# sync history across panes/sessions immediately
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ls/grep/ll/la/l/alert aliases now come from programs.bash.shellAliases in
# home/programs/bash.nix

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# bash completion (programs.bash.enableCompletion, on by default) and fzf
# key bindings/completion (programs.bash.enableCompletion / programs.fzf)
# are wired up by home-manager itself

# rust, only when installed outside nix (rustup)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# fnm - SUPERSEDED by nix (nodejs_22 in home/common.nix).
# Uncommenting puts fnm's node/npm ahead of nix's on PATH.
# FNM_PATH="$HOME/.local/share/fnm"
# if [ -d "$FNM_PATH" ]; then
#   export PATH="$FNM_PATH:$PATH"
#   eval "$(fnm env)"
# fi

# sdkman - SUPERSEDED by nix (jdk21 in home/common.nix).
# Uncommenting puts sdkman's java ahead of nix's on PATH, and this block must
# then move below the nix block at the end of this file.
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# pnpm global install dir (the pnpm binary itself comes from nix)
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# nix / home-manager
# Deliberately LAST: every block above prepends to PATH, so this has to run
# after them to win. ~/.profile prepends a few more dirs *after* sourcing this
# file - keep those nix-free or they will shadow the nix profile again.
if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi
for _d in "/nix/var/nix/profiles/default/bin" "$HOME/.nix-profile/bin"; do
  case ":$PATH:" in
    *":$_d:"*) ;;
    *) [ -d "$_d" ] && PATH="$_d:$PATH" ;;
  esac
done
unset _d
export PATH

# starship prompt now comes from home-manager's programs.starship
