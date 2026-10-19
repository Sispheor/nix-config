#!/usr/bin/env bash
# Prepare an already-installed NixOS VM; do not activate the configuration.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/bootstrap.sh [--update]

Prepare this checkout for the perso configuration on a freshly installed NixOS
VM. Copy the installed hardware configuration (backing up the old copy), check
prerequisites, and print the rebuild command. No rebuild or reboot is performed.

  --update  Update all flake inputs; otherwise keep flake.lock unchanged.
  --help    Show this help.
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

update=false
for arg in "$@"; do
  case "$arg" in
    --update) update=true ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; die "Unknown argument: $arg" ;;
  esac
done

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
hardware_source=/etc/nixos/hardware-configuration.nix
hardware_target="$repo_dir/hosts/perso/hardware-configuration.nix"
nix_flags=(--option experimental-features 'nix-command flakes')

[[ -e /etc/NIXOS ]] || die 'Run this on the installed NixOS system, after booting from its disk.'
[[ $(uname -m) == x86_64 ]] || die 'The perso configuration requires x86_64-linux.'
[[ -r "$hardware_source" ]] || die "Cannot read $hardware_source. Finish the minimal NixOS installation first."
[[ -f "$hardware_target" && -f "$repo_dir/flake.lock" ]] || die 'Expected a complete checkout of this repository.'
[[ -w "$hardware_target" && -w "$repo_dir" ]] || die 'Run from a checkout owned by your user.'

for command in nix nixos-rebuild git curl lsblk findmnt getent; do
  command -v "$command" >/dev/null || die "Missing $command. Enter 'nix-shell -p git curl util-linux' and run this script again."
done
getent passwd nico >/dev/null || die "Create the nico account in the minimal installation and set its password before proceeding."
if (( EUID != 0 )); then
  command -v sudo >/dev/null || die 'sudo is required to run the printed rebuild command.'
  sudo -v || die 'Root access is required for the subsequent rebuild.'
fi

# The hardware file describes filesystems, but does not select the bootloader.
[[ ! -d /sys/firmware/efi ]] || die 'This VM boots with UEFI. Adapt hosts/perso/default.nix to the installed EFI bootloader before using this bootstrap.'
[[ -b /dev/sda ]] || die 'The configuration installs BIOS GRUB on /dev/sda, but that disk does not exist. Adapt hosts/perso/default.nix first.'
root_device=$(findmnt -n -o SOURCE /)
# Strip a possible btrfs subvolume suffix before querying block ancestry.
root_device=${root_device%%\[*}
root_disks=$(lsblk -s -n -r -p -o NAME "$root_device")
on_sda=false
while IFS= read -r device; do
  if [[ "$device" == /dev/sda ]]; then
    on_sda=true
  fi
done <<< "$root_disks"
"$on_sda" || die 'The root filesystem is not on /dev/sda. Review the hard-coded GRUB device in hosts/perso/default.nix first.'

# Check network access before changing the checkout or fetching flake inputs.
curl --fail --silent --show-error --location --connect-timeout 15 --max-time 30 \
  --output /dev/null https://github.com/NixOS/nixpkgs || die 'Cannot reach GitHub. Check networking, DNS, and the system clock.'

if cmp -s "$hardware_source" "$hardware_target"; then
  printf 'Hardware configuration already matches the installed system.\n'
else
  backup_dir="$repo_dir/.bootstrap-backups"
  mkdir -p -- "$backup_dir"
  backup=$(mktemp "$backup_dir/hardware-configuration.XXXXXXXX.nix")
  cp -- "$hardware_target" "$backup"
  cp -- "$hardware_source" "$hardware_target"
  printf 'Previous hardware configuration saved to %s\n' "$backup"
  printf 'Copied %s to %s\n' "$hardware_source" "$hardware_target"
fi

if "$update"; then
  printf 'Updating all flake inputs...\n'
  (cd -- "$repo_dir" && nix "${nix_flags[@]}" flake update)
else
  printf 'Keeping the versions pinned in flake.lock.\n'
fi

printf '\nPreparation complete. Review the hardware changes:\n\n'
printf '  git -C %q diff -- hosts/perso/hardware-configuration.nix flake.lock\n' "$repo_dir"
printf '\nApply the configuration with:\n\n'
printf '  sudo nixos-rebuild switch --option experimental-features %q --flake %q\n' \
  'nix-command flakes' "$repo_dir#perso"
printf '\nAfter a successful rebuild, reboot to use the new kernel and desktop.\n'
