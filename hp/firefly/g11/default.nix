{ pkgs, lib, ... }:

{
  imports =
    [
      ../../../common/pc/laptop
      ../../../common/pc/laptop/acpi_call.nix
      ../../../common/pc/laptop/ssd
      ../../../common/cpu/intel
      ../../../common/gpu/nvidia
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelPackages = lib.mkIf (lib.versionOlder pkgs.linux.version "6.3") (lib.mkDefault pkgs.linuxPackages_latest);

  boot.kernelParams = [
    "i915.enable_psr=1" # Fix from here https://discourse.nixos.org/t/intel-12th-gen-igpu-freezes/21768/4
    "nvidia-drm.fbdev=1" # https://discourse.nixos.org/t/drm-kernel-driver-nvidia-drm-in-use-nvk-requires-nouveau/42222/18
  ];

  # Make VDPAU_DRIVER (from intel settings) work
  # https://bbs.archlinux.org/viewtopic.php?pid=1496664#p1496664
  hardware.opengl.extraPackages = with pkgs; [
    libvdpau-va-gl
  ];

  hardware.intelgpu = {
    driver = lib.mkDefault "xe";
    loadInInitrd = lib.mkDefault false;
  };

  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0"; # pci@0000:00:02.0
    nvidiaBusId = "PCI:1:0:0"; # pci@0000:01:00.0
  };

  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
