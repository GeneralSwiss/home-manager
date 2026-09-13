# home-manager

One user environment, reproducible on Linux and macOS.

## How it is split

Two layers, with a deliberate line between them:

| Layer | Owns | Where |
|---|---|---|
| **Nix / Home Manager** | Packages and toolchain — same tools at the same versions on every machine | `home.nix`, `flake.nix` |
| **Dotfiles** | Behaviour — zsh, tmux, Neovim | `dotfiles/`, symlinked into `$HOME` |

Home Manager can express config either way. Nix options (`programs.tmux.mouse = true`)
are tidy for a handful of booleans, but the Neovim config is a ten-file Lua project;
restating that in the Nix DSL means maintaining it twice. So Nix installs, dotfiles
configure.

Because of that split, **`programs.zsh` and `programs.tmux` are intentionally not
enabled** — those modules generate their own `~/.zshrc` and `~/.config/tmux/tmux.conf`
and would fight the linked files.

Files are linked with [`mkOutOfStoreSymlink`][mkoss], which points at the working copy
in this repo rather than a read-only copy in `/nix/store`. A Neovim tweak is therefore
live the moment you save it — no `home-manager switch` in the edit loop.

[mkoss]: https://nixos-and-flakes.thiscute.world/best-practices/accelerating-dotfiles-debugging

## Layout

```
flake.nix          machine list; one mkHome line per box
home.nix           packages, env, dotfile links -- shared by all machines
linux.nix          Linux-only (xclip)
darwin.nix         macOS-only (pngpaste)
dotfiles/
  zsh/zshrc        login shell: aliases, zinit plugins, fzf, zoxide
  tmux/tmux.conf   mouse, scrollback
  nvim/            submodule -> GeneralSwiss/nvim-config
```

## First install on a new machine

```bash
# 1. Nix (Determinate installer; needs sudo)
./bootstrap.sh

# 2. Clone with the Neovim submodule
git clone --recurse-submodules https://github.com/GeneralSwiss/home-manager.git \
  ~/.config/home-manager
cd ~/.config/home-manager

# 3. Clear the way -- see the trap below
mv ~/.zshrc ~/.zshrc.pre-hm 2>/dev/null
mv ~/.tmux.conf ~/.tmux.conf.pre-hm 2>/dev/null
mv ~/.config/nvim ~/.config/nvim.pre-hm 2>/dev/null

# 4. Activate (pick the entry matching the machine)
nix run home-manager/master -- switch --flake .#nick@ubuntu
```

Machine targets: `nick@ubuntu` (x86_64 Linux), `nick@oldbox` (older Linux),
`nick@mac` (Apple Silicon), `nick@mac-intel`. The names are labels, not hostnames
— rename freely, they only have to match the `#target` you pass to `switch`.

### Old glibc machines

This is the case Nix earns its keep on. A stock Neovim binary needs `GLIBC_2.34`,
which rules out RHEL 8 (2.28), Ubuntu 20.04 (2.31) and anything older. Nix-built
binaries link the store's own glibc — their ELF interpreter points at
`/nix/store/…/ld-linux-x86-64.so.2`, not `/lib64` — so the host's version stops
mattering.

That covers what Nix installs. It does **not** cover Mason, which downloads
prebuilt binaries at runtime and is still subject to the host glibc. Hence the
language servers in `home.nix`, and `dotfiles/nvim/lua/plugins/nix-lsp.lua`,
which detects a server already on PATH and tells Mason to stand down for it.
Machines without those packages keep the Mason behaviour untouched.

### The collision trap

Home Manager refuses to overwrite a file it does not already manage. If `~/.zshrc`
exists as a real file, the first `switch` aborts with a collision error naming it.
Move the originals aside first (step 3) — that is the whole fix, and keeping them as
`.pre-hm` gives you something to diff against if a setting seems to have vanished.

## Daily use

```bash
home-manager switch --flake ~/.config/home-manager#nick@ubuntu   # apply changes
nix flake update                                                 # bump pins
home-manager generations                                         # list rollback points
```

Editing anything under `dotfiles/` needs no switch — the symlinks are live. A switch is
only needed after changing a `.nix` file.

### Updating Neovim config

`dotfiles/nvim` is a submodule with its own history:

```bash
cd dotfiles/nvim && git pull && cd -
git commit -am "chore(nvim): bump submodule"
```

## Adding a machine

One entry in `flake.nix`:

```nix
"nick@newbox" = mkHome { system = "aarch64-linux"; platformModule = ./linux.nix; };
```

## Known gaps

- **tmux resurrect/continuum** were configured under the old `programs.tmux` block and
  are not in `dotfiles/tmux/tmux.conf`. They were never active (Home Manager had not
  run on this machine). Restore via tpm if wanted.
- **Terminal emulator theming is not tracked.** The GNOME Terminal profile lives in
  dconf and does not port to macOS. Deliberate — palette is per-machine.
- **`stateVersion` is `26.05`.** It pins migration semantics for a first install; it is
  not a "keep current" field and should not be bumped casually.
