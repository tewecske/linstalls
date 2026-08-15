{ ... }:
{
  # replaces the out-of-store symlink to git/.gitconfig; home-manager writes
  # this to $XDG_CONFIG_HOME/git/config
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "tewe";
        email = "leventewe@gmail.com";
      };
      core.editor = "nvim";
      alias.lg = "log --decorate --oneline --graph";
      rerere.enabled = true;
      merge.tool = "nvimdiff";
      mergetool = {
        prompt = false;
        keepBackup = false;
        "nvimdiff".layout = "LOCAL,BASE,REMOTE / MERGED";
      };
    };
  };
}
