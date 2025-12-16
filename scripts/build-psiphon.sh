#!/usr/bin/env bash
set -euxo pipefail

OPENWRT_VERSION="$1"
TARGET="$2"
SUBTARGET="$3"
PKGARCH="$4"

SDK_NAME="openwrt-sdk-${OPENWRT_VERSION}-${TARGET}-${SUBTARGET}_gcc-13.3.0_musl"

if [[ "$PKGARCH" == arm_* && "$PKGARCH" != aarch64_* ]]; then
  SDK_NAME="${SDK_NAME}_eabi"
fi


SDK_TARBALL="${SDK_NAME}.Linux-x86_64.tar.zst"
SDK_URL="https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/${TARGET}/${SUBTARGET}/${SDK_TARBALL}"

echo "Downloading SDK: $SDK_URL"
axel -n 8 "$SDK_URL"

tar -xf "$SDK_TARBALL"
SDK_DIR="$(tar -tf "$SDK_TARBALL" | sed -n '1s|/.*||p')"
cd "$SDK_DIR"

# feeds
./scripts/feeds update -a

echo "Applying Go patch (1.24.8)"

rm -rf feeds/packages/lang/golang
rm -rf temp
mkdir temp
cd temp

git clone --no-checkout --depth=1 --filter=tree:0 https://github.com/openwrt/packages
cd packages
git sparse-checkout set --no-cone lang/golang
git checkout

sed -i 's/GO_VERSION_MAJOR_MINOR:=1.25/GO_VERSION_MAJOR_MINOR:=1.24/' \
  lang/golang/golang/Makefile
sed -i 's/GO_VERSION_PATCH:=5/GO_VERSION_PATCH:=8/' \
  lang/golang/golang/Makefile
sed -i 's|22a5fd0a91efcd28a1b0537106b9959b2804b61f59c3758b51e8e5429c1a954f|b1ff32c5c4a50ddfa1a1cb78b60dd5a362aeb2184bb78f008b425b62095755fb|' \
  lang/golang/golang/Makefile

cd ../../
cp -r temp/packages/lang/golang feeds/packages/lang
rm -rf temp

# Inject psiphon package
cp -r "$GITHUB_WORKSPACE/psiphon-tunnel-core" feeds/packages/net/

./scripts/feeds update -a
./scripts/feeds install psiphon-tunnel-core

make defconfig
make package/psiphon-tunnel-core/compile -j$(nproc)

# Locate IPK
IPK_PATH=$(find bin/packages -name 'psiphon_*.ipk' | head -n1)

FINAL_NAME="psiphon_v${OPENWRT_VERSION}_${PKGARCH}_${TARGET}_${SUBTARGET}.ipk"

mkdir -p "$GITHUB_WORKSPACE/artifacts"
cp "$IPK_PATH" "$GITHUB_WORKSPACE/artifacts/$FINAL_NAME"

echo "Built: $FINAL_NAME"
