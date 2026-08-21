# bash build-apple.sh

# HarfBuzz

source common.sh

# Define some global variables
freetype_framework_path='/Users/evgenij/Developer/Xcode projects/FreeType/Binaries/libfreetype.xcframework'
png_framework_path='/Users/evgenij/Developer/Xcode projects/LibPNG/Binaries/png.xcframework'
libbrotlicommon_framework_path='/Users/evgenij/Developer/Xcode projects/Brotli/Binaries/libbrotlicommon.xcframework'
libbrotlienc_framework_path='/Users/evgenij/Developer/Xcode projects/Brotli/Binaries/libbrotlienc.xcframework'
libbrotlidec_framework_path='/Users/evgenij/Developer/Xcode projects/Brotli/Binaries/libbrotlidec.xcframework'
platforms_path='/Applications/Xcode.app/Contents/Developer/Platforms'
# Your signing identity to sign the xcframework. Execute "security find-identity -v -p codesigning" and select one from the list
identity=070BA25D98F2A17A61E3E27E31BE64C06F901016

# HarfBuzz source code folder
source_name="harfbuzz-14.3.1"


# Create the build directory if not exists
mkdir -p build-apple


# Remove logs if exist
rm -f "build-apple/log.txt"

# -L\"/Users/evgenij/Developer/Xcode projects/Brotli/Binaries/libbrotlidec.xcframework/macos-arm64_x86_64\" -llibbrotlidec
make_pkg_config() {
  local name=$1
  local libname=$2
  local build_name=$3
  local prefix=${4}
  local extra=${5}

  mkdir -p build-apple/$build_name/pkg-config
  rm -f   "build-apple/$build_name/pkg-config/$name.pc"
  # idk wtf meson.build expects freetype version to be at least 12.0.6 when the latest official version is 2.13.3, so we just define our own version
  echo \
"prefix=${prefix}
exec_prefix=\${prefix}
libdir=\${exec_prefix}
includedir=\${prefix}/Headers 

Name: $name
Description: some description
Version: 1000.0.0
$extra
Libs: -L\"\${libdir}\" -l$libname -lz -lbz2
Cflags: -I\"\${includedir}\"
" \
>> "build-apple/$build_name/pkg-config/$name.pc"
  exit_if_error
}


# Compile the library for specific OS and architecture
build_library() {
  local platform_name=$1
  local arch=$2
  local target_os=$3

  # Determine config name
  local arch_name="$platform_name/$arch"
  local build_name="$arch_name/build"
  local install_name="$arch_name/install"

  # Determine meson cpu settings
  if [[ "$arch" == "arm64" ]]; then
    local meson_cpu="arm64"
    local meson_cpu_family="aarch64"
  elif [[ "$arch" == "x86_64" ]]; then
    local meson_cpu="x86"
    local meson_cpu_family="x86_64"
  else
    echo "Unknown architecture"
    exit 1
  fi


  # Remove build directory for the current platform if exists
  rm -rf build-apple/$arch_name
  exit_if_error

  # Welcome message
  echo "Build for ${bold}$build_name${normal}"
  mkdir -p build-apple/$build_name

  # Remove config file if exists
  rm -f "build-apple/$build_name.txt"
  exit_if_error

  # Generate meson config file for cross-compile
  echo \
"[binaries]
c = 'clang'
cpp = 'clang++'
objcpp = 'clang++'
ar = 'ar'
strip = 'strip'
pkg-config = 'pkg-config'

[host_machine]
system = 'darwin'
cpu_family = '$meson_cpu_family'
cpu = '$meson_cpu'
endian = 'little'

[built-in options]
c_args = ['-isysroot', '$platforms_path/$platform_name.platform/Developer/SDKs/$platform_name.sdk', '-arch', '$arch', '-mtargetos=$target_os', '-O2']
cpp_args = ['-isysroot', '$platforms_path/$platform_name.platform/Developer/SDKs/$platform_name.sdk', '-arch', '$arch', '-mtargetos=$target_os', '-O2']
c_link_args = ['-isysroot', '$platforms_path/$platform_name.platform/Developer/SDKs/$platform_name.sdk', '-arch', '$arch', '-mtargetos=$target_os']
cpp_link_args = ['-isysroot', '$platforms_path/$platform_name.platform/Developer/SDKs/$platform_name.sdk', '-arch', '$arch', '-mtargetos=$target_os']" \
>> "build-apple/$build_name.txt"
  exit_if_error


  # Create custom pkg-config file for freetype to target specific platform and architecture
  mkdir -p build-apple/$build_name/
  if [[ "$platform_name" == "MacOSX" ]]; then
    local framework_target="macos-arm64_x86_64"
  elif [[ "$platform_name" == "iPhoneOS" ]]; then
    local framework_target="ios-$arch"
  elif [[ "$platform_name" == "iPhoneSimulator" ]]; then
    local framework_target="ios-arm64_x86_64-simulator"
  elif [[ "$platform_name" == "AppleTVOS" ]]; then
    local framework_target="tvos-$arch"
  elif [[ "$platform_name" == "AppleTVSimulator" ]]; then
    local framework_target="tvos-arm64_x86_64-simulator"
  elif [[ "$platform_name" == "WatchOS" ]]; then
    local framework_target="watchos-$arch"
  elif [[ "$platform_name" == "WatchSimulator" ]]; then
    local framework_target="watchos-arm64_x86_64-simulator"
  elif [[ "$platform_name" == "XROS" ]]; then
    local framework_target="xros-$arch"
  elif [[ "$platform_name" == "XRSimulator" ]]; then
    local framework_target="xros-arm64_x86_64-simulator"
  else
    echo "Unknown platform $platform_name"
    exit 1
  fi

  # The build system checks if all symbols are provided. LibPNG is linked to Brotli, thus we also generate .pc files for them.

  local libbrotlicommon_path="$libbrotlicommon_framework_path/$framework_target"
  make_pkg_config libbrotlicommon libbrotlicommon $build_name "${libbrotlicommon_path}"

  local libbrotlienc_path="$libbrotlienc_framework_path/$framework_target"
  make_pkg_config libbrotlienc libbrotlienc $build_name "${libbrotlienc_path}"

  local libbrotlidec_path="$libbrotlidec_framework_path/$framework_target"
  make_pkg_config libbrotlidec libbrotlidec $build_name "${libbrotlidec_path}"

  local png_path="$png_framework_path/$framework_target"
  make_pkg_config libpng libpng16 $build_name "${png_path}" "Requires: libbrotlicommon >= 0.1 libbrotlienc >= 0.1 libbrotlidec >= 0.1"

  local freetype_path="$freetype_framework_path/$framework_target"
  make_pkg_config freetype2 libfreetype $build_name "${freetype_path}" "Requires: libpng >= 0.1"
  

  # Setup meson build
  echo "Configure meson"
  meson setup build-apple/$build_name $source_name \
    --cross-file build-apple/$build_name.txt \
    --prefix=$(pwd)/build-apple/$install_name \
    -Dstrip=true \
    -Dpkg_config_path="$(pwd)/build-apple/$build_name/pkg-config" \
    -Dcpp_std=c++20 \
    -Ddefault_library=static \
    -Dicu=disabled \
    -Dglib=disabled \
    -Dgobject=disabled \
    -Dcairo=disabled \
    -Dchafa=disabled \
    -Dfreetype=enabled \
    -Dpng=enabled \
    -Dcoretext=enabled \
    -Dgpu=enabled \
    -Dtests=disabled \
    -Dintrospection=disabled \
    -Ddocs=disabled \
    -Dbuildtype=minsize >> build-apple/log.txt
  exit_if_error
  
  # Build
  echo "Build"
  meson compile -C build-apple/$build_name
  exit_if_error

  # Install compiled libraries and headers into the install folder
  meson install -C build-apple/$build_name

  # Strip installed libraries
  strip -S build-apple/$install_name/lib/libharfbuzz-gpu.a
  strip -S build-apple/$install_name/lib/libharfbuzz-raster.a
  strip -S build-apple/$install_name/lib/libharfbuzz-subset.a
  strip -S build-apple/$install_name/lib/libharfbuzz-vector.a
  strip -S build-apple/$install_name/lib/libharfbuzz.a
  exit_if_error

  # Remove temporary build files to free some disk space
  rm -rf build-apple/$build_name
  exit_if_error
}


build_library MacOSX           arm64  macos11
build_library MacOSX           x86_64 macos10.13
build_library iPhoneOS         arm64  ios12
build_library iPhoneSimulator  arm64  ios14-simulator
build_library iPhoneSimulator  x86_64 ios12-simulator
build_library AppleTVOS        arm64  tvos12
build_library AppleTVSimulator arm64  tvos12-simulator
build_library AppleTVSimulator x86_64 tvos12-simulator
build_library WatchOS          arm64  watchos8
build_library WatchSimulator   arm64  watchos8-simulator
build_library WatchSimulator   x86_64 watchos8-simulator
build_library XROS             arm64  xros1
build_library XRSimulator      arm64  xros1-simulator
build_library XRSimulator      x86_64 xros1-simulator


create_framework() {
  local name=$1
  local use_platform=$2
  local include=$3
  local folder=$4

  # Remove previously created framework if exists
  rm -rf build-apple/$name.xcframework
  exit_if_error

  # Merge macOS arm and x86 binaries
  mkdir -p build-apple/MacOSX
  exit_if_error
  lipo -create -output build-apple/MacOSX/$name.a \
    build-apple/MacOSX/arm64/install/lib/$name.a \
    build-apple/MacOSX/x86_64/install/lib/$name.a
  exit_if_error

  # Merge iOS simulator arm and x86 binaries
  mkdir -p build-apple/iPhoneSimulator
  exit_if_error
  lipo -create -output build-apple/iPhoneSimulator/$name.a \
    build-apple/iPhoneSimulator/arm64/install/lib/$name.a \
    build-apple/iPhoneSimulator/x86_64/install/lib/$name.a
  exit_if_error

  # Merge tvOS simulator arm and x86 binaries
  mkdir -p build-apple/AppleTVSimulator
  exit_if_error
  lipo -create -output build-apple/AppleTVSimulator/$name.a \
    build-apple/AppleTVSimulator/arm64/install/lib/$name.a \
    build-apple/AppleTVSimulator/x86_64/install/lib/$name.a
  exit_if_error

  # Merge watchOS simulator arm and x86 binaries
  mkdir -p build-apple/WatchSimulator
  exit_if_error
  lipo -create -output build-apple/WatchSimulator/$name.a \
    build-apple/WatchSimulator/arm64/install/lib/$name.a \
    build-apple/WatchSimulator/x86_64/install/lib/$name.a
  exit_if_error

  # Merge visionOS simulator arm and x86 binaries
  mkdir -p build-apple/XRSimulator
  exit_if_error
  lipo -create -output build-apple/XRSimulator/$name.a \
    build-apple/XRSimulator/arm64/install/lib/$name.a \
    build-apple/XRSimulator/x86_64/install/lib/$name.a
  exit_if_error

  if [[ "$use_platform" == "true" ]]; then
    local platform_macos="MacOSX/arm64/"
    local platform_ios="iPhoneOS/arm64/"
    local platform_ios_sim="iPhoneSimulator/arm64/"
    local platform_appletv="AppleTVOS/arm64/"
    local platform_appletv_sim="AppleTVSimulator/arm64/"
    local platform_watchos="WatchOS/arm64/"
    local platform_watchos_sim="XRSimulator/arm64/"
    local platform_visionos="XROS/arm64/"
    local platform_visionos_sim="XRSimulator/arm64/"
  else
    local platform_macos=""
    local platform_ios=""
    local platform_ios_sim=""
    local platform_appletv=""
    local platform_appletv_sim=""
    local platform_watchos=""
    local platform_watchos_sim=""
    local platform_visionos=""
    local platform_visionos_sim=""
  fi

  # Create the framework with multiple platforms
  xcodebuild -create-xcframework \
    -library build-apple/MacOSX/$name.a                      -headers $include/$platform_macos$folder \
    -library build-apple/iPhoneOS/arm64/install/lib/$name.a  -headers $include/$platform_ios$folder \
    -library build-apple/iPhoneSimulator/$name.a             -headers $include/$platform_ios_sim$folder \
    -library build-apple/AppleTVOS/arm64/install/lib/$name.a -headers $include/$platform_appletv$folder \
    -library build-apple/AppleTVSimulator/$name.a            -headers $include/$platform_appletv_sim$folder \
    -library build-apple/WatchOS/arm64/install/lib/$name.a   -headers $include/$platform_watchos$folder \
    -library build-apple/WatchSimulator/$name.a              -headers $include/$platform_watchos_sim$folder \
    -library build-apple/XROS/arm64/install/lib/$name.a      -headers $include/$platform_visionos$folder \
    -library build-apple/XRSimulator/$name.a                 -headers $include/$platform_visionos_sim$folder \
    -output build-apple/$name.xcframework
  exit_if_error

  # And sign the framework
  codesign --timestamp -s $identity build-apple/$name.xcframework
  exit_if_error
}
create_framework "libharfbuzz" true "build-apple" "install/include/harfbuzz"
create_framework "libharfbuzz-gpu" false "Contents/Headers/libharfbuzz_gpu" ""
create_framework "libharfbuzz-raster" false "Contents/Headers/libharfbuzz_raster" ""
create_framework "libharfbuzz-subset" false "Contents/Headers/libharfbuzz_subset" ""
create_framework "libharfbuzz-vector" false "Contents/Headers/libharfbuzz_vector" ""








# 8===o