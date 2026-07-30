let
  kernels = final: prev: (import ./default.nix { pkgs = prev; });

  cixComponent = final: prev: {
    cix-component-srcs = final.callPackage ../cix-component/srcs.nix { };
    mkCixDebPackage = final.callPackage ../cix-component/mkDebPackage.nix { };
  };

  drivers = final: prev: {
    cix-gpu-umd = final.callPackage ../drivers/gpu { };
    cix-npu-umd = final.callPackage ../drivers/npu { };
    cix-isp-umd = final.callPackage ../drivers/isp { };
    cix-vpu-firmware = (final.callPackage ../drivers/vpu { }).vpu-firmware;

    cix-libdrm = final.callPackage ../graphics/libdrm.nix { };
    cix-mesa = final.callPackage ../graphics/mesa.nix { };
    cix-libglvnd = final.callPackage ../graphics/libglvnd.nix { };

    cix-gstreamer = final.callPackage ../multimedia/gstreamer.nix { };
    cix-audio-dsp = final.callPackage ../multimedia/audio-dsp.nix { };
    cix-cpipe = final.callPackage ../multimedia/cpipe.nix { };

    cix-llama-cpp = final.callPackage ../ai/llama-cpp.nix { };
    cix-mnn = final.callPackage ../ai/mnn.nix { };

    cix-gpu-test = final.callPackage ../testing/gpu-test.nix { };
    cix-vpu-test = final.callPackage ../testing/vpu-test.nix { };

    cix-firmware = final.callPackage ../firmware { };
    cix-grub-efi = final.callPackage ../firmware/grub-efi.nix { };
    cix-optee = final.callPackage ../firmware/optee.nix { };
    cix-tools = final.callPackage ../cix-tools { };
  };
in
{
  inherit kernels drivers cixComponent;

  default = final: prev: cixComponent final prev // kernels final prev // drivers final prev;
}
