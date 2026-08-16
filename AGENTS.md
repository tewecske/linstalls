# AGENTS.md

Guidance for coding agents working in this repo.

## What this is

`~/linstalls` is a standalone (flake-based) home-manager config that provisions
the `tewe` dev environment identically on WSL2, Ubuntu, Fedora, and NixOS. Nix
is the single source of tooling — sdkman, `cs setup`, fnm, and `go install` are
all superseded (see `README.md` "What replaced what").

## Layout

- `flake.nix` — inputs (nixpkgs `nixos-unstable`, home-manager, opencode) + one
  `homeConfigurations` entry per host.
- `home/common.nix` — shared packages + dotfile symlinks; imports `home/programs/*.nix`.
- `home/{wsl,ubuntu,fedora,nixos}.nix` — per-host overrides; each sets `HM_TARGET`.
- `home/programs/*.nix` — one module per program (bash, git, tmux, fzf, starship, zoxide, dircolors, home-manager).
- `bash/`, `scripts/` — dotfiles symlinked out-of-store to `~/`.
- `home/programs/tmux.nix` — all tmux config (options, plugins, bindings); no `tmux/` dir.
- `examples/devenv.nix` — optional per-project toolchain.
- `linstalls.log`, `nix_stuff.txt`, `windows_setup.txt` — historical notes, not config.

## Conventions

- Dotfiles under `bash/`, `scripts/` use `mkOutOfStoreSymlink` to point
  at `~/linstalls/...` instead of the nix store. Editing them is live — no switch
  needed. Only adding/removing a *file* requires a switch.
- tmux is configured natively via `programs.tmux` (options + `plugins` from
  `pkgs.tmuxPlugins` + `extraConfig`). No tpm, no hand-written `tmux.conf`.
- nvim is NOT managed here — it's a separate repo at `~/.config/nvim`.
  Language servers come from nix (Mason removed).
- Formatter: `nixfmt-rfc-style` (run `nix fmt`). 2-space indent; section banners
  use `### ... ###` comment blocks.
- `home.stateVersion = "25.05"` — pinning migration behavior, do not bump casually.
- `flake.lock` is committed; two machines share byte-identical tooling.

## Common tasks

| task | command |
|---|---|
| apply changes | `hm switch` |
| build without activating | `hm build` |
| upstream changes | `hm news` |
| add a package | edit `home/common.nix`, then `hm switch` |
| update everything | `nix flake update` then `hm switch` |
| format | `nix fmt` |
| find a package | `nix search nixpkgs <name>` |
| first run (existing dotfiles) | `home-manager switch -b backup --flake ~/linstalls#tewe@<host>` |

`hm` is a wrapper in `bash/.bash_aliases` that supplies `--flake`; it reads
`HM_TARGET` (set per host). Everything needs `--flake` because the config is not
at the default `~/.config/home-manager/home.nix`.

## Gotchas

- PATH ordering in `bash/.bashrc`: the nix block is deliberately LAST. Any block
  that prepends to PATH after it (e.g. re-enabled fnm/sdkman/go) shadows nix.
- NixOS host needs `programs.nix-ld.enable = true` in `/etc/nixos/configuration.nix`.
- Fedora host runs `scripts/display-hotplug` as a systemd user unit (`display-hotplug`);
  restart with `systemctl --user restart display-hotplug` after editing.
- OpenGL on non-NixOS hosts (WSL/Ubuntu): nix's loader can't see the host's
  `/usr/lib/x86_64-linux-gnu`, so GL apps fail with `GLX: Failed to load GLX`.
  Run them through `nixGLIntel <cmd>` (aliased to `sbt` in `bash/.bash_aliases`).

## Author

tewe <leventewe@gmail.com> (GitHub: tewecske)
