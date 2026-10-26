# NixOS configuration

Personal `x86_64-linux` NixOS configurations for hosts `appart` and `hpe`, with
Home Manager integrated into the system rebuild and user `nico`. Select the host
to deploy using the corresponding flake output (`#appart` or `#hpe`). Shared
system basics live in `modules/common.nix`. Two independent flags in `flake.nix`
select additional system and Home Manager modules; both default to `false`:

- `workstation = true` imports `modules/workstation.nix` and
  `users/workstation.nix`: development and UI applications (including VS Code,
  PyCharm, Firefox, and Ghostty), `nix-ld`, and local DNS overrides.
- `desktop = true` imports `modules/desktop.nix` and `users/desktop.nix`:
  KDE/SDDM, Niri, Noctalia, printing, PipeWire, Nixdatifier, and the Nextcloud
  background service. It also selects the Noctalia theme when Ghostty is enabled.

Both current hosts enable both flags. A future WSL2 host can keep the workstation
applications without a local desktop session by setting:

```nix
workstation = true;
desktop = false;
```

The host's WSL2 integration belongs in its own `hosts/<host>` configuration.

## Bootstrap after a minimal installation

1. Install minimal NixOS to the VM's disk and boot into the installed system.
   Create user `nico` with a password and membership in `wheel` so it can use
   `sudo`. Connect to the network and make sure the system clock is correct.
   Keep the generated `/etc/nixos/hardware-configuration.nix`.

   Both current host configurations expect **BIOS boot with GRUB on `/dev/sda`**.
   Choose that layout when creating/installing the VM. For UEFI or a different
   boot disk, adapt the bootloader settings in `hosts/<host>/default.nix` and
   the bootstrap checks before proceeding.

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
   HOST=appart # use hpe when setting up the hpe VM
   bash scripts/bootstrap.sh --host "$HOST"
   ```

   Run bootstrap as your normal user from a writable checkout. It checks sudo
   access, boot mode, root disk, and connectivity to GitHub. It replaces
   `hosts/<host>/hardware-configuration.nix` for the selected host with the
   freshly installed system's file, picking up the new filesystem UUIDs and
   hardware modules. The previous copy is saved under the Git-ignored
   `.bootstrap-backups/` directory. Repeating the script with an identical
   hardware file does not create another backup.

   The hardware file stays tracked in Git so flake evaluation can use it without
   `--impure`. Review and commit the new hardware configuration when appropriate.
   The generated file does not select the bootloader; those settings remain in
   `hosts/<host>/default.nix`.

   When working from a local Git checkout, add any newly created host or module
   files to Git before using `--flake .#<host>`; Git-backed flakes omit untracked
   files. A fresh clone already has these files tracked.

3. Review the diff and execute the rebuild command printed by bootstrap. For the
   checkout location above, this is:

   ```bash
   git diff -- "hosts/$HOST/hardware-configuration.nix" flake.lock
   sudo nixos-rebuild switch \
     --option experimental-features 'nix-command flakes' \
     --flake "$HOME/nixos-config#$HOST"
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
`/etc/nixos/configuration.nix` is not used by rebuilds with `--flake ...#$HOST`.

### Versions and updates

By default, bootstrap keeps the versions in `flake.lock`. This configuration
tracks `nixos-unstable`; the lock file selects its exact revision. There is no
separate channel upgrade required before applying the flake. The lock file is
shared by both hosts: each rebuild uses the input revisions in its checkout.

To explicitly update **all** inputs during preparation:

```bash
HOST=appart # or hpe, on the corresponding VM
bash scripts/bootstrap.sh --host "$HOST" --update
```

Review the resulting `flake.lock` changes before rebuilding. On an already
configured system, update and rebuild with:

```bash
cd ~/nixos-config
HOST=appart # or hpe, on the corresponding VM
nix flake update
sudo nixos-rebuild switch --flake ".#$HOST"
```

`system.stateVersion` and `home.stateVersion` are currently `26.05` on both
hosts. These control compatibility defaults, not the package release. Review
them for your fresh installation; do not increase them as part of routine
package updates.

## Project development with mise

`users/modules/mise.nix` installs mise and enables automatic environment loading
in Zsh. The host's `nix-ld` support lets mise use precompiled Python interpreters
instead of building Python from source. Global interactive commands such as
`mise use --global` remain available through a mutable user configuration.

After rebuilding, open a new terminal. In a project with a `mise.toml`, run:

```bash
mise trust
mise install
```

The project's tools and configured virtualenv are then selected automatically
when entering its directory. Keep native libraries and development headers in a
project-local Nix shell when needed; mise does not supply those dependencies.

Project-specific native environments can also live in Home Manager. The
[development modules](users/modules/development/README.md) provide
`tower-automation-shell`, keeping Nix-specific support out of the shared project.
