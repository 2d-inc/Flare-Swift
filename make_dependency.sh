#!/bin/sh

# Requires depot_tools and git: 
#   https://skia.org/user/download
# Build notes:
#   https://skia.org/user/build

# Default builds for arm64 devices and outputs in build_device.
ARCH="arm64"
BUILD_DIR="../../../lib/build_device"

# Reads flags.
# Currently on -s is supported, and builds for a Simulator.
while getopts ":s" opt; do 
  case $opt in
  s)
    echo "Build for Simulator." >&2
    ARCH="x64" # Build for simulator.
    BUILD_DIR="../../../lib/build_simulator"
    ;;
  \?)
    echo "invalid option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done

cd FlareSkia/Skia/src

python tools/git-sync-deps

./bin/gn gen $BUILD_DIR \
  --args="extra_cflags_cc=[\"-frtti\", \"-fembed-bitcode\"] \
  is_official_build=true \
  target_os=\"ios\" \
  skia_use_bitcode=true \
  skia_use_angle=false \
  skia_use_dng_sdk=false \
  skia_use_egl=false \
  skia_use_expat=false \
  skia_use_fontconfig=false \
  skia_use_freetype=true \
  skia_use_system_freetype2=false \
  skia_use_icu=false \
  skia_use_libheif=false \
  skia_use_libjpeg_turbo=false \
  skia_use_libpng=true \
  skia_use_system_libpng=false \
  skia_use_libwebp=false \
  skia_use_lua=false \
  skia_use_piex=false \
  skia_use_vulkan=false \
  skia_use_metal=false \
  skia_use_zlib=true \
  skia_use_system_zlib=false \
  skia_enable_ccpr=false \
  skia_enable_skottie=false \
  skia_enable_skshaper=false \
  skia_enable_gpu=true \
  skia_enable_fontmgr_empty=false \
  skia_enable_spirv_validation=false \
  skia_enable_pdf=false
  \
  is_debug=false \
  skia_enable_flutter_defines=true \
  skia_gl_standard=\"gles\"
  skia_use_sfntly=false \
  skia_use_wuffs=true \
  skia_use_x11=false \
  target_cpu=\"$ARCH\""

ninja -C $BUILD_DIR
