{ ... }:
{
  # Fedora. Nix installed via the multi-user installer.
  #
  # SELinux note: if `home-manager switch` fails on /nix permissions, the
  # Determinate Systems installer handles Fedora/SELinux more cleanly than
  # the upstream one. See README.md.

  # Which homeConfiguration this machine is; read by the `hm` shell wrapper.
  home.sessionVariables.HM_TARGET = "tewe@fedora";

  # Host-only packages / settings go here.
}
