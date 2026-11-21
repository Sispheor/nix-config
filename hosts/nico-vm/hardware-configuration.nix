# Replace this placeholder with the generated /etc/nixos/hardware-configuration.nix
# from nico-vm by running scripts/bootstrap.sh --host nico-vm on the installed VM.
{ ... }:

{
  assertions = [
    {
      assertion = false;
      message = "nico-vm needs its generated hardware configuration; run scripts/bootstrap.sh --host nico-vm on the installed VM";
    }
  ];
}
