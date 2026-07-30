{
  description = "NixOS flake for Radxa Orion O6 (CIX CD8180 Sky1 SoC)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      targetSystem = "aarch64-linux";

      overlays = import ./pkgs/kernel/overlays.nix;

      unfree = import ./lib/unfree.nix { lib = nixpkgs.lib; };
      allowUnfreePredicate = unfree.allowCixSky1Unfree;
    in
    {
      overlays.default = overlays.default;

      nixosModules.orion-o6 = import ./modules/orion-o6.nix;

      packages."aarch64-linux" =
        let
          pkgs = import nixpkgs {
            system = targetSystem;
            overlays = [ overlays.default ];
            config.allowUnfreePredicate = allowUnfreePredicate;
          };
          kernelPkgs = import ./pkgs/kernel { pkgs = pkgs; };
        in
        {
          inherit (kernelPkgs) cixVendorKernelPackages cixVendorKernel;
          inherit (pkgs) cix-firmware cix-vpu-firmware cix-tools
            cix-gpu-umd cix-npu-umd cix-isp-umd
            cix-libdrm cix-mesa cix-libglvnd
            cix-gstreamer cix-audio-dsp cix-cpipe
            cix-llama-cpp cix-mnn
            cix-gpu-test cix-vpu-test
            cix-grub-efi cix-optee
            cix-component-srcs;
        };

      devShells."aarch64-linux".default =
        let
          pkgs = import nixpkgs {
            system = targetSystem;
            overlays = [ overlays.default ];
            config.allowUnfreePredicate = allowUnfreePredicate;
          };
        in
        pkgs.mkShell {
          name = "nixos-cix-orion-o6-dev";
          packages = with pkgs; [ git nixpkgs-fmt ];
          shellHook = ''
            echo "NixOS CIX Orion O6 Development Environment"
            echo "nix flake check       - Check flake"
            echo "nix build .#cixVendorKernel - Build kernel"
          '';
        };
    };
}
