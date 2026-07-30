{ pkgs }:

let
  vendorKernel = pkgs.callPackage ./vendor.nix { };
in
{
  cixVendorKernelPackages = pkgs.linuxPackagesFor vendorKernel;
  cixVendorKernel = vendorKernel;
}
