#!/bin/bash

# Exit the script immediately if any command exits with a non-zero status.
set -e

# Check the system architecture to ensure compatibility.
# This script only supports x86_64 (64-bit Intel/AMD) and aarch64 (64-bit ARM).
# If the architecture does not match, the script exits with an error message.
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" ]]; then
  echo "Unsupported architecture: $ARCH. Only x86_64 and ARM64 (aarch64) are supported."
  exit 1
fi

# Define the URL for the Determinate Systems Nix installer.
# This URL points to an installer script maintained by Determinate Systems, which provides
# a reliable and compatible way to install Nix on various systems.
DETERMINATE_INSTALLER_URL="https://install.determinate.systems/nix"

# Install Nix by downloading and executing the installer script from the defined URL.
# The `-L` flag allows curl to follow redirects, ensuring the latest script version is used.
# This command pipes the downloaded script to `sh`, which runs it directly.
echo "Installing Nix using the Determinate Systems installer..."
curl -L "$DETERMINATE_INSTALLER_URL" | sh -s -- install

# Load the Nix environment to make Nix commands available in the current shell session.
# The script checks for the presence of `nix-daemon.sh`, which sets up essential environment variables.
# If `nix-daemon.sh` is missing, the script exits with an error, as this indicates an incomplete installation.
if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "Failed to locate nix-daemon.sh for environment setup. Exiting."
  exit 1
fi

# Print a completion message, indicating that Nix has been successfully installed and
# configured. The user is now ready to continue with any additional setup, such as
# configuring Home Manager, which can be handled separately.
echo "Bootstrap complete! Nix is installed and configured. You can proceed with your Home Manager setup using Git."
