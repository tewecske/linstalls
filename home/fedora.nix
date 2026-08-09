{ config, ... }:
{
  # Fedora. Nix installed via the multi-user installer.
  #
  # SELinux note: if `home-manager switch` fails on /nix permissions, the
  # Determinate Systems installer handles Fedora/SELinux more cleanly than
  # the upstream one. See README.md.

  # Which homeConfiguration this machine is; read by the `hm` shell wrapper.
  home.sessionVariables.HM_TARGET = "tewe@fedora";

  # Start/restart changed user units on switch instead of only printing a hint.
  systemd.user.startServices = "sd-switch";

  #############################################################################
  # Monitor hotplug (i3 + X11)
  #
  # X leaves an unplugged output enabled, so i3 keeps workspaces on a screen
  # that is no longer there and the windows on them are unreachable. This unit
  # watches drm uevents and runs scripts/display-hotplug, which turns dead
  # outputs off (i3 then pulls those workspaces back by itself), lays out
  # whatever is plugged in, and moves audio between the HDMI and analog card
  # profiles.
  #
  # No root involved: `udevadm monitor --udev` works unprivileged, and lightdm
  # already puts DISPLAY/XAUTHORITY into the `systemctl --user` environment.
  # Not tied to graphical-session.target — lightdm never activates it.
  #############################################################################
  systemd.user.services.display-hotplug = {
    Unit = {
      Description = "Reconfigure displays and audio on monitor hotplug (i3/X11)";
      Documentation = "file://${config.home.homeDirectory}/linstalls/scripts/display-hotplug";
    };

    Service = {
      # ~/bin/scripts is the out-of-store symlink to this repo's scripts/, so
      # editing the script and restarting the unit is enough — no rebuild.
      ExecStart = "${config.home.homeDirectory}/bin/scripts/display-hotplug --watch";
      Restart = "always";
      RestartSec = 5;
      # udevadm / xrandr / i3-msg / pactl are Fedora's; jq comes from nix.
      Environment = [
        "PATH=${config.home.homeDirectory}/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
      ];
    };

    Install.WantedBy = [ "default.target" ];
  };
}
