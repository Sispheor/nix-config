# NixOS configuration

Personal `x86_64-linux` NixOS configuration for host `perso`, with Home Manager
integrated into the system rebuild and user `nico`.

## Bootstrap after a minimal installation

1. Install minimal NixOS to the VM's disk and boot into the installed system.
   Create user `nico` with a password and membership in `wheel` so it can use
   `sudo`. Connect to the network and make sure the system clock is correct.
   Keep the generated `/etc/nixos/hardware-configuration.nix`.

   The current host configuration expects **BIOS boot with GRUB on `/dev/sda`**.
   Choose that layout when creating/installing the VM. For UEFI or a different
   boot disk, adapt the bootloader settings in `hosts/perso/default.nix` and the
   bootstrap checks before proceeding.

   For **VMware Workstation**, enable **VM Settings → Display → Accelerate 3D
   graphics** before starting the VM. Niri needs working 3D acceleration; with
   this option disabled, login through SDDM can lead to a black screen instead
   of the Niri/Noctalia desktop.

   Selecting **no desktop** in the NixOS installer is fine: this flake installs
   and enables SDDM, Niri, and Noctalia during the rebuild below.

2. Log in as `nico`, temporarily obtain Git, and clone using HTTPS (no SSH key
   required):

   ```bash
   nix-shell -p git curl util-linux
   git clone https://github.com/Sispheor/nix-config.git ~/nixos-config
   cd ~/nixos-config
   bash scripts/bootstrap.sh
   ```

   Run bootstrap as your normal user from a writable checkout. It checks sudo
   access, boot mode, root disk, and connectivity to GitHub. It replaces
   `hosts/perso/hardware-configuration.nix` with the freshly installed system's
   file, picking up the new filesystem UUIDs and hardware modules. The previous
   copy is saved under the Git-ignored `.bootstrap-backups/` directory. Repeating
   the script with an identical hardware file does not create another backup.

   The hardware file stays tracked in Git so flake evaluation can use it without
   `--impure`. Review and commit the new hardware configuration when appropriate.
   The generated file does not select the bootloader; those settings remain in
   `hosts/perso/default.nix`.

3. Review the diff and execute the rebuild command printed by bootstrap. For the
   checkout location above, this is:

   ```bash
   git diff -- hosts/perso/hardware-configuration.nix flake.lock
   sudo nixos-rebuild switch \
     --option experimental-features 'nix-command flakes' \
     --flake "$HOME/nixos-config#perso"
   ```

   This builds and activates both the system and Home Manager configuration.
   Bootstrap itself does **not** rebuild, reboot, or modify `/etc/nixos`.
   The first rebuild downloads and builds the desktop and development tools,
   so allow sufficient disk space and time.

4. After the rebuild succeeds, reboot:

   ```bash
   sudo reboot
   ```

Keep this checkout for future configuration changes. The minimal installation's
`/etc/nixos/configuration.nix` is not used by rebuilds with `--flake ...#perso`.

### Versions and updates

By default, bootstrap keeps the versions in `flake.lock`. This configuration
tracks `nixos-unstable`; the lock file selects its exact revision. There is no
separate channel upgrade required before applying the flake.

To explicitly update **all** inputs during preparation:

```bash
bash scripts/bootstrap.sh --update
```

Review the resulting `flake.lock` changes before rebuilding. On an already
configured system, update and rebuild with:

```bash
cd ~/nixos-config
nix flake update
sudo nixos-rebuild switch --flake .#perso
```

`system.stateVersion` and `home.stateVersion` are currently `26.05`. These control
compatibility defaults, not the package release. Review them for your fresh
installation; do not increase them as part of routine package updates.
