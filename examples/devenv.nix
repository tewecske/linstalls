{ pkgs, ... }:

# Example per-project environment. Copy into a project root alongside an
# .envrc containing `use devenv`, then `direnv allow`.
#
# Only for projects that need something DIFFERENT from the machine-wide set in
# ~/linstalls/home/common.nix. If the base env already suffices, skip devenv.
#
# Docs: https://devenv.sh/basics/
{
  # Pin a toolchain for this project only.
  languages.scala.enable = true;
  languages.java.enable = true;
  languages.java.jdk.package = pkgs.jdk21;

  # languages.go.enable = true;
  # languages.javascript.enable = true;
  # languages.javascript.package = pkgs.nodejs_20;   # older than the base env

  # Project-scoped extras that don't belong on every machine.
  packages = with pkgs; [
    # sqlite
    # tailwindcss
  ];

  # services.postgres.enable = true;

  # processes.web.exec = "air";

  enterShell = ''
    echo "$(java -version 2>&1 | head -1)"
  '';
}
