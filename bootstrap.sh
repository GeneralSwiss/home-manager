#!/usr/bin/env bash
#
# Install Nix, and only Nix.
#
# Applying the Home Manager configuration is deliberately left to the caller:
# installing a package manager and activating a user environment fail in
# different ways and are re-run at different times, and a script that does both
# has to be resumable across the boundary. The exact follow-up commands are
# printed on success.
#
# Usage: ./bootstrap.sh [--dry-run] [--yes]

set -euo pipefail

readonly INSTALLER_URL="https://install.determinate.systems/nix"
# The installer writes here regardless of which shell the caller uses.
readonly NIX_PROFILE_BIN="/nix/var/nix/profiles/default/bin/nix"

dry_run=false
assume_yes=false

log()  { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'USAGE'
Usage: ./bootstrap.sh [options]

Installs the Nix package manager via the Determinate Systems installer.

Options:
  --dry-run   Print what would happen without changing anything.
  --yes       Pass --no-confirm to the installer (for unattended runs).
  --help      Show this message.
USAGE
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) dry_run=true ;;
      --yes|-y)  assume_yes=true ;;
      --help|-h) usage; exit 0 ;;
      *)         usage >&2; die "unknown argument: $1" ;;
    esac
    shift
  done
}

# Normalise what the kernel reports into the two names used elsewhere.
#
# This is the one that bites: macOS reports Apple Silicon as `arm64`, while
# Linux reports the same hardware as `aarch64`. Comparing the raw value against
# `aarch64` alone rejects every M-series Mac.
detect_platform() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$arch" in
    x86_64|amd64)  arch="x86_64" ;;
    arm64|aarch64) arch="aarch64" ;;
    *) die "unsupported architecture: $arch (need x86_64 or arm64/aarch64)" ;;
  esac

  case "$os" in
    Linux|Darwin) ;;
    *) die "unsupported operating system: $os (need Linux or Darwin)" ;;
  esac

  platform_os="$os"
  platform_arch="$arch"
}

require_commands() {
  local missing=()
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  [[ ${#missing[@]} -eq 0 ]] || die "missing required command(s): ${missing[*]}"
}

nix_is_installed() {
  command -v nix >/dev/null 2>&1 || [[ -x "$NIX_PROFILE_BIN" ]]
}

install_nix() {
  local -a installer_args=(install)
  [[ "$assume_yes" == true ]] && installer_args+=(--no-confirm)

  if [[ "$dry_run" == true ]]; then
    log "+ curl --proto '=https' --tlsv1.2 -sSfL $INSTALLER_URL | sh -s -- ${installer_args[*]}"
    return 0
  fi

  log "Installing Nix (Determinate Systems installer)..."
  # --proto/--tlsv1.2 refuse a downgraded transport; -f makes curl exit non-zero
  # on an HTTP error instead of printing the error body, which would otherwise
  # be piped straight into sh and executed.
  curl --proto '=https' --tlsv1.2 -sSfL "$INSTALLER_URL" | sh -s -- "${installer_args[@]}"
}

# Confirm the thing we care about exists, rather than trusting an exit status.
#
# Note this cannot put nix on the *caller's* PATH: sourcing the profile script
# here would only alter this script's shell, which exits moments later. Hence
# the instruction to open a new shell.
verify_installation() {
  if [[ "$dry_run" == true ]]; then
    log "+ [ -x $NIX_PROFILE_BIN ]"
    return 0
  fi
  [[ -x "$NIX_PROFILE_BIN" ]] || die "installer finished but $NIX_PROFILE_BIN is missing"
}

print_next_steps() {
  local target
  if [[ "$platform_os" == "Darwin" ]]; then
    [[ "$platform_arch" == "aarch64" ]] && target="nick@mac" || target="nick@mac-intel"
  else
    target="nick@ubuntu"
  fi

  cat <<NEXT

Nix is installed. Open a new shell, then:

  # Move aside any config Home Manager is about to take over; it refuses to
  # overwrite files it does not already manage, and aborts on the first one.
  for f in ~/.zshrc ~/.tmux.conf ~/.config/nvim; do
    [ -e "\$f" ] && mv "\$f" "\$f.pre-hm"
  done

  nix run home-manager/master -- switch --flake ~/.config/home-manager#$target

Detected: $platform_os/$platform_arch
NEXT
}

main() {
  parse_args "$@"
  detect_platform
  require_commands curl uname

  if nix_is_installed; then
    log "Nix is already installed; skipping installation."
  else
    install_nix
    verify_installation
  fi

  print_next_steps
}

main "$@"
