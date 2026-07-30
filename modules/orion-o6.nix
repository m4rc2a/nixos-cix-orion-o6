{ config, pkgs, lib, ... }:

let
  cixOverlay = import ../pkgs/kernel/overlays.nix;
in
{
  nixpkgs.overlays = [ cixOverlay.default ];

  boot = {
    kernelPackages = pkgs.cixVendorKernelPackages;

    extraModulePackages = with (pkgs.callPackage ../pkgs/kernel-modules { kernel = config.boot.kernelPackages.kernel; }); [
      mali-gpu
      aipu-npu
      armcb-isp
      mvx-vpu
    ];

    kernelParams = [
      "rootwait"
      "consoleblank=0"
    ];

    initrd = {
      includeDefaultModules = lib.mkForce false;

      availableKernelModules = [
        "nvme"
        "mmc_block"
        "usb_storage"
        "usbhid"
        "xhci_pci"
        "r8169"
        "dm_mod"
        "hid"
        "hid_generic"
      ];
    };

    kernelModules = [ ];

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [
      pkgs.cix-firmware
      pkgs.cix-vpu-firmware
    ];
  };

  environment.systemPackages = with pkgs; [
    cix-gpu-umd
    cix-npu-umd
    cix-isp-umd
    cix-libdrm
    cix-mesa
    cix-libglvnd
    cix-gstreamer
    cix-tools
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
}
