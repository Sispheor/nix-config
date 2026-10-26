# NixOS configuration

Personal `x86_64-linux` NixOS configurations for hosts `appart`, `hpe`, and `wls2`, with
Home Manager integrated into the system rebuild and user `nico`. Select the host
to deploy using the corresponding flake output (`#appart`, `#hpe`, or `#wls2`). Shared
system basics live in `modules/common.nix`. Two independent flags in `flake.nix`
select additional system and Home Manager modules; both default to `false`:

- `workstation = true` imports `modules/workstation.nix` and
  `users/workstation.nix`: development and UI applications (including VS Code,
  PyCharm, Firefox, and Ghostty), `nix-ld`, and local DNS overrides.
- `desktop = true` imports `modules/desktop.nix` and `users/desktop.nix`:
  KDE/SDDM, Niri, Noctalia, printing, PipeWire, Nixdatifier, and the Nextcloud
  background service. It also selects the Noctalia theme when Ghostty is enabled.

The VM hosts `appart` and `hpe` enable both flags. The WSL2 host `wls2` keeps the
workstation applications without a local desktop session by setting:

```nix
workstation = true;
desktop = false;
```

`hosts/wls2/default.nix` enables NixOS-WSL with `nico` as the default user and
keeps networking and DNS under WSL's control, overriding the shared
NetworkManager and local dnsmasq settings. GUI applications use WSLg.

## Install on WSL2 (`wls2`)

This procedure targets an x86-64 Windows machine with a current WSL2/WSLg
installation. The flake host name is **`wls2`**; the Windows distribution name
below is **`NixOS`**.

1. In PowerShell, update WSL and download `nixos.wsl` from the
   [latest official NixOS-WSL release](https://github.com/nix-community/NixOS-WSL/releases/latest).
   Install and open it (the `--from-file` option requires WSL 2.4.4 or later):

   ```powershell
   wsl --update
   wsl --install --from-file "$HOME\Downloads\nixos.wsl" --name NixOS
   wsl -d NixOS
   ```

2. In the new NixOS shell, set the initial `nixos` user's password and prepare a
   checkout in the Linux filesystem:

   ```bash
   passwd
   sudo nix-channel --update
   nix-shell -p git --run 'git clone https://github.com/Sispheor/nix-config.git ~/nixos-config'
   cd ~/nixos-config
   ```

   Use a revision containing the `wls2` configuration. If testing local changes,
   transfer them into this checkout and track new files with Git before rebuilding.

3. Build the complete system and Home Manager configuration for the next start:

   ```bash
   sudo nixos-rebuild boot \
     --option experimental-features 'nix-command flakes' \
     --flake "$PWD#wls2"
   exit
   ```

   Use `boot` for this first rebuild because it changes the default user from
   `nixos` to `nico`. There is no hardware configuration or GRUB installation for
   this host; follow this WSL procedure rather than `scripts/bootstrap.sh`.

4. In PowerShell, apply the new generation using the
   [NixOS-WSL username-change restart sequence](https://nix-community.github.io/NixOS-WSL/how-to/change-username.html),
   then set `nico`'s password and open the default user's shell:

   ```powershell
   wsl --terminate NixOS
   wsl -d NixOS --user root -- exit
   wsl --terminate NixOS
   wsl -d NixOS --user root -- passwd nico
   wsl -d NixOS
   ```

5. In the new shell, verify the user and move the checkout into its permanent
   location. For a fresh official image, the initial user's home is `/home/nixos`:

   ```bash
   whoami # should print nico
   hostname # should print wls2
   sudo mv /home/nixos/nixos-config "$HOME/nixos-config"
   sudo chown -R nico:users "$HOME/nixos-config"
   cd ~/nixos-config
   systemctl status home-manager-nico.service --no-pager
   command -v mise pycharm code firefox
   firefox
   ```

   Firefox should open through WSLg on the Windows desktop. PyCharm (`pycharm`)
   and VS Code (`code`) can be launched in the same way. Home Manager should show
   a successful activation. Niri, Noctalia, KDE, and SDDM are disabled on this host.

For subsequent rebuilds, run inside WSL:

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#wls2
```

When a restart is needed after changing WSL settings, exit the shell and run
`wsl --terminate NixOS` followed by `wsl -d NixOS` from PowerShell.

## Bootstrap a VM after a minimal installation (`appart` / `hpe`)

1. Install minimal NixOS to the VM's disk and boot into the installed system.
   Create user `nico` with a password and membership in `wheel` so it can use
   `sudo`. Connect to the network and make sure the system clock is correct.
   Keep the generated `/etc/nixos/hardware-configuration.nix`.

   Both VM host configurations expect **BIOS boot with GRUB on `/dev/sda`**.
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
shared by all hosts: each rebuild uses the input revisions in its checkout.

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

`system.stateVersion` and `home.stateVersion` are currently `26.05` on all
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
