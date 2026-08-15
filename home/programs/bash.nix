{ ... }:
{
  programs.bash = {
    enable = true;
    initExtra = builtins.readFile ../../bash/.bashrc;
    profileExtra = builtins.readFile ../../bash/.profile;

    # was HISTCONTROL/HISTIGNORE/HISTSIZE/HISTFILESIZE in bash/.bashrc
    historyControl = [ "ignoreboth" ];
    historyIgnore = [
      "ls"
      "ll"
      "ls -la"
      "pwd"
      "clear"
      "history"
    ];
    historySize = 2000;
    historyFileSize = 10000;

    # was `shopt -s histappend` / `shopt -s checkwinsize` in bash/.bashrc;
    # deliberately narrower than the module default (which also turns on
    # globstar/extglob/checkjobs).
    shellOptions = [
      "histappend"
      "checkwinsize"
    ];

    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      alert = ''notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"'';
    };
  };
}
