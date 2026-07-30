{ lib }:

{
  allowCixSky1Unfree = pkg: builtins.elem (lib.getName pkg) [
    "cix-gpu-umd"
    "cix-npu-umd"
    "cix-isp-umd"
    "cix-vpu-firmware"
    "cix-firmware"
    "cix-tools"
  ];
}
