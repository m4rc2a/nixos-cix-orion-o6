{ lib
, fetchFromGitHub
, linuxManualConfig
, ubootTools
, ccache
, ...
}:

let
  modDirVersion = "6.6.89";

  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "linux-orangepi";
    rev = "f41a4f0b22c0f85a645aa207435761a0123feeaf";
    hash = "sha256-RI8X9lBXS/UIkTY0BQyo3u6S+t4EZWnAZvWHkJaHRZ0=";
  };

  ccacheConfig = ''
    export CCACHE_DIR=/tmp/ccache
    export CCACHE_COMPRESS=1
    export CCACHE_MAXSIZE=10G
  '';
in
(linuxManualConfig {
  inherit modDirVersion src;
  version = "${modDirVersion}-sky1";

  extraMeta = {
    description = "Vendor kernel for CIX CD8180/CD8160 SoC (Sky1) with Orion O6 support";
    maintainers = [ ];
    platforms = lib.platforms.linux;
    badPlatforms = lib.filter (p: !(lib.hasInfix "x86_64" p || lib.hasInfix "aarch64" p)) lib.platforms.linux;
  };

  configfile = ./sky1_vendor_config;

  kernelPatches = [
    {
      name = "fwnode-regulator-fix-type-error";
      patch = ./patches/fwnode-regulator-fix-type-error.patch;
    }
    {
      name = "rtl-wifi-fix-makefile-includes";
      patch = ./patches/rtl-wifi-fix-makefile-includes.patch;
    }
    {
      name = "rtl-wifi-fix-halrf-includes";
      patch = ./patches/rtl-wifi-fix-halrf-includes.patch;
    }
    {
      name = "rtl-wifi-fix-aes-include-path";
      patch = ./patches/rtl-wifi-fix-aes-include-path.patch;
    }
    {
      name = "rtl8192eu-fix-makefile-includes";
      patch = ./patches/rtl8192eu-fix-makefile-includes.patch;
    }
    {
      name = "rtl8812au-fix-makefile-includes";
      patch = ./patches/rtl8812au-fix-makefile-includes.patch;
    }
    {
      name = "rtl8723ds-fix-makefile-includes";
      patch = ./patches/rtl8723ds-fix-makefile-includes.patch;
    }
    {
      name = "isp-driver-install-mntn-header";
      patch = ./patches/isp-driver-install-mntn-header.patch;
    }
  ];

  allowImportFromDerivation = true;

}).overrideAttrs (old: {
  name = "k";

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ ubootTools ccache ];

  makeFlags = (old.makeFlags or [ ]) ++ [ "ARCH=arm64" ];

  preBuild = (old.preBuild or "") + ''
    echo "ccache: Starting build with persistent cache"
    ${ccacheConfig}
    ccache --zero-stats
    if [[ "$CC" != *ccache* ]]; then
      export CC="ccache $CC"
    fi
  '';

  postBuild = old.postBuild or "" + ''
    echo "ccache statistics for this build:"
    ccache --show-stats
  '';

  postInstall = (old.postInstall or "") + ''
    echo "Installing device tree blobs..."
    mkdir -p $out/dtbs/cix
    if [ -d arch/arm64/boot/dts/cix ]; then
      cp arch/arm64/boot/dts/cix/*.dtb $out/dtbs/cix/
      echo "Installed DTBs:"
      ls -lh $out/dtbs/cix/*.dtb
    else
      echo "Warning: No CIX device tree blobs found in arch/arm64/boot/dts/cix"
    fi
  '';
})
