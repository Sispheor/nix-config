# Project development environments

These Home Manager modules provide native dependencies for individual projects.
They use the importing configuration's `pkgs`, so package versions follow its
`flake.lock`. There is no separate nixpkgs download or pin in the project.

## Tower automation

Import `tower-automation.nix` in your Home Manager configuration:

```nix
{
  imports = [
    ./modules/mise.nix
    ./modules/development/tower-automation.nix
  ];
}
```

The generic `mise.nix` module installs mise and enables Zsh integration. The
project module installs the `tower-automation-shell` command, which supplies:

- GCC and pkg-config for building Python extensions.
- OpenLDAP and Cyrus SASL headers and libraries for `python-ldap`.
- OpenSSL, libffi, zlib, and the C++ runtime for native extensions and wheels.
- Mise with precompiled Python enabled and Bash activation in the shell.

Python versions and Python dependencies remain defined by the project's
`mise.toml` and requirements files. The module does not install them globally.

### Host prerequisite

Enable support for upstream Linux binaries in the NixOS configuration:

```nix
programs.nix-ld.enable = true;
```

This is a NixOS option, not a Home Manager option. It is already enabled for
`perso` in this repository.

### Apply and use

Rebuild the NixOS configuration, then open a new terminal:

```bash
sudo nixos-rebuild switch --flake 'path:/home/nico/nixos-config#perso'
```

From your tower-automation checkout, enter the native development environment:

```bash
cd /path/to/tower-automation
tower-automation-shell
```

For initial project setup:

```bash
mise trust
mise install
mise run setup
mise run galaxy
mise run pre-commit-install
mise run check
```

On later visits, enter `tower-automation-shell` and run your Ansible commands.
Mise activates the project's `.venv` in the shell. Use `exit` to leave.

The command forwards arguments to `nix-shell`, including noninteractive commands:

```bash
tower-automation-shell --run 'mise run check'
```

To use your configured Zsh and its mise integration instead of Bash:

```bash
tower-automation-shell --run zsh
```

### Share with another NixOS user

Copy this module and, optionally, `../mise.nix` into the coworker's configuration
and add the corresponding Home Manager imports. The project module itself has
no dependency on the generic mise module: the default Bash shell includes and
activates mise. The generic module adds activation outside that shell and in Zsh.

Enable `nix-ld` on their host and rebuild. Neither a username nor a checkout path
is embedded in the module; the command uses the directory it is launched from.
The coworker's configuration supplies its own pinned nixpkgs version.

The shared tower-automation repository needs no Nix-specific configuration.
