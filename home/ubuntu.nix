{ ... }:
{
  # Bare-metal Ubuntu. Nix installed via the multi-user installer.
  # Host-only packages / settings go here.

  # Which homeConfiguration this machine is; read by the `hm` shell wrapper.
  home.sessionVariables.HM_TARGET = "tewe@ubuntu";
}
