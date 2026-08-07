{ ... }:
{
  # NixOS. Nix is already present; only home-manager is layered on top.
  #
  # !! REQUIRED SYSTEM-LEVEL CHANGE (not settable from home-manager) !!
  #
  # ~/.config/nvim uses mason.nvim, which downloads prebuilt, dynamically
  # linked LSP binaries that expect /lib64/ld-linux-x86-64.so.2. NixOS has no
  # such path, so every mason-installed server fails to exec.
  #
  # Fix, in this machine's /etc/nixos/configuration.nix:
  #
  #     programs.nix-ld.enable = true;
  #     programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc.lib zlib openssl ];
  #
  # then `sudo nixos-rebuild switch`.
  #
  # Alternative: drop mason from init.lua and take LSP servers from nixpkgs
  # (gopls, metals, nil, rust-analyzer are already in home/common.nix).

  # Which homeConfiguration this machine is; read by the `hm` shell wrapper.
  home.sessionVariables.HM_TARGET = "tewe@nixos";

  # Host-only packages / settings go here.
}
