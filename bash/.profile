# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# .bashrc is sourced separately by ~/.bash_profile (home-manager generated);
# no need to include it here too.

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/bin/scripts" ] ; then
    PATH="$HOME/bin/scripts:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# SUPERSEDED by nix (go in home/common.nix). This runs *after* .bashrc, so
# uncommenting puts the apt/manual go ahead of nix's.
# if [ -d "/usr/local/go/bin" ] ; then
#     PATH="/usr/local/go/bin:$PATH"
# fi

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# >>> coursier install directory >>>
# `cs setup` is no longer used; kept so anything installed via `cs install`
# (e.g. metals fetched by nvim-metals) stays on PATH.
if [ -d "$HOME/.local/share/coursier/bin" ] ; then
    PATH="$PATH:$HOME/.local/share/coursier/bin"
fi
# <<< coursier install directory <<<


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/home/tewe/.opam/opam-init/init.sh' && . '/home/tewe/.opam/opam-init/init.sh' > /dev/null 2> /dev/null || true
# END opam configuration
