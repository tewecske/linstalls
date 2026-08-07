# linstalls

Reproducible dev environment for WSL, Ubuntu, Fedora and NixOS, via
[home-manager](https://github.com/nix-community/home-manager) (standalone, flake-based).

Nix provides **all** the tooling. `sdkman`, `cs setup`, `fnm` and `go install`
are no longer used — see [What replaced what](#what-replaced-what).

```
flake.nix              # inputs + one homeConfiguration per machine
home/common.nix        # packages + dotfile symlinks (shared by all machines)
home/{wsl,ubuntu,fedora,nixos}.nix
bash/                  # .bashrc .profile .bash_aliases   -> symlinked to ~
tmux/                  # tmux.conf tmux.reset.conf        -> symlinked to ~/.config/tmux
git/.gitconfig         #                                  -> symlinked to ~
scripts/               #                                  -> symlinked to ~/bin/scripts
examples/devenv.nix    # optional per-project toolchains
linstalls.log          # historical record of the old manual install
```

---

## Bootstrap a machine

### 1. Install nix — *this is the manual step*

Skip on **NixOS** (nix is already there; go to step 2).

Recommended, on WSL / Ubuntu / Fedora — the Determinate Systems installer, which
turns flakes on by default and handles SELinux (Fedora) and WSL correctly:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

<details>
<summary>Upstream installer instead</summary>

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```
</details>

Then **open a new shell** so `/nix` lands on `PATH`, and check:

```sh
nix --version
```

> WSL only: the multi-user install needs systemd. This machine already has
> `systemd=true` in `/etc/wsl.conf`. On a fresh WSL instance, add it, then
> `wsl --shutdown` from Windows first.

### 2. Clone this repo

```sh
git clone git@github.com:<you>/linstalls.git ~/linstalls
```

The path must be `~/linstalls` — `home/common.nix` symlinks dotfiles out of it.

### 3. Apply home-manager

home-manager needs **no separate install**; `nix run` fetches it:

```sh
cd ~/linstalls
nix run home-manager/master -- switch -b backup --flake .#tewe@wsl
```

Swap the last argument per machine: `.#tewe@ubuntu`, `.#tewe@fedora`, `.#tewe@nixos`.

`-b backup` is required on the **first** run: `~/.bashrc`, `~/.profile` and
`~/.gitconfig` already exist, and home-manager refuses to clobber unmanaged files.
It renames them to `*.backup`. Later runs don't need the flag.

After the first switch, `home-manager` is on `PATH`:

```sh
home-manager switch --flake ~/linstalls#tewe@wsl
```

### 4. Neovim config

Not managed by nix on purpose — it's a separate repo and `lazy.nvim` writes
`lazy-lock.json` into it, which a read-only `/nix/store` path would break.

```sh
git clone git@github.com:tewecske/kickstart.nvim.git ~/.config/nvim
```

### 5. tmux plugins

`home-manager switch` clones tpm into `~/.config/tmux/plugins/tpm` automatically.
Install the rest from inside tmux with `prefix + I` (prefix is `^A`).

tpm derives `TMUX_PLUGIN_MANAGER_PATH` from wherever it finds `tmux.conf`. With
the XDG layout (`~/.config/tmux/tmux.conf`) that resolves to
`~/.config/tmux/plugins/`, so `tmux.conf` loads tpm from that same directory —
one clone, not two.

### 6. NixOS only — mason needs nix-ld

`~/.config/nvim` uses `mason.nvim`, which downloads prebuilt dynamically linked
binaries expecting `/lib64/ld-linux-x86-64.so.2`. NixOS has no such path, so
every mason-installed LSP fails to exec. In `/etc/nixos/configuration.nix`:

```nix
programs.nix-ld.enable = true;
programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc.lib zlib openssl ];
```

then `sudo nixos-rebuild switch`. Unnecessary on WSL/Ubuntu/Fedora.

---

## Daily use

| | |
|---|---|
| apply changes | `home-manager switch --flake ~/linstalls#tewe@wsl` |
| add a package | edit `home/common.nix`, then switch |
| update everything | `nix flake update` in `~/linstalls`, then switch |
| roll back | `home-manager generations`, then run the listed generation's `activate` |
| find a package name | `nix search nixpkgs ripgrep` |
| format the nix files | `nix fmt` |

`flake.lock` pins every input — commit it. Two machines on the same lock get
byte-identical tooling.

### Editing dotfiles

`bash/`, `tmux/`, `git/` and `scripts/` are linked with
`mkOutOfStoreSymlink`, so they point at `~/linstalls/...` rather than into the
nix store. Edit them and the change is live — **no switch needed**. Only adding
or removing a *file* needs a switch.

---

## What replaced what

| was | now |
|---|---|
| `sdkman` → jdk | `jdk21` |
| `cs setup`, `cs install mill` | `scala_3` `sbt` `mill` `metals` |
| `fnm use --install-if-missing 20` | `nodejs_22`, `pnpm` |
| `go install .../air`, `.../templ` + manual `~/bin` symlinks | `air`, `templ` |
| `apt install ripgrep jq fzf` etc. | one `home.packages` list |
| `curl … starship.rs/install.sh` | `starship` |
| `rustup` | `rustc` `cargo` `rust-analyzer` |

`coursier` is still installed: `nvim-metals` shells out to `cs` for
`:MetalsInstall`. It is a tool now, not an environment manager — no `cs setup`.

Dropped, per your call: `pdftotext` (poppler-utils), `7zip`, `zoxide`, `fd-find`.
Commented out in `home/common.nix`: `sqlite`, `tailwindcss`.

---

## Optional: per-project toolchains with devenv

home-manager gives every machine the same base environment. **devenv** is a
different axis — per-*directory* toolchains that activate on `cd`, for when a
project needs a JDK or Node version that differs from the base.

You don't need it to get started; it layers on later with no rework.

```sh
nix profile install nixpkgs#devenv nixpkgs#direnv
cd ~/projects/some-repo
cp ~/linstalls/examples/devenv.nix .
echo 'use devenv' > .envrc && direnv allow
```

See `examples/devenv.nix`. Files: `devenv.nix` (config), `devenv.yaml`
(inputs), `devenv.lock` (pins). Docs: <https://devenv.sh>.

---

## Not covered here

- SSH keys — copy them in before cloning (`linstalls.log` lines 4-6).
- Windows-side WSL setup — see `windows_setup.txt`.
- `sops`/`age` key material — see `nix_stuff.txt`.
