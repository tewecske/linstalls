{ ... }:
{
  # WSL2 (Ubuntu image). Nix installed via the multi-user installer.
  #
  # Nothing WSL-specific is required for the toolchain itself. Add host-only
  # packages / settings here.

  # Which homeConfiguration this machine is; read by the `hm` shell wrapper.
  home.sessionVariables.HM_TARGET = "tewe@wsl";

  # home.packages = with pkgs; [ wslu ];   # wslview, wslpath helpers
  # home.sessionVariables.BROWSER = "wslview";
}
