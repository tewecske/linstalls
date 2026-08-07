{ ... }:
{
  # WSL2 (Ubuntu image). Nix installed via the multi-user installer.
  #
  # Nothing WSL-specific is required for the toolchain itself. Add host-only
  # packages / settings here.

  # home.packages = with pkgs; [ wslu ];   # wslview, wslpath helpers
  # home.sessionVariables.BROWSER = "wslview";
}
