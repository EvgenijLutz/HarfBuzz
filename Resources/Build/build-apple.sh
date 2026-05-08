# bash build-apple.sh

# HarfBuzz

source common.sh

# Define some global variables
freetype_framework_path='/Users/evgenij/Developer/Xcode projects/FreeType/Binaries/libfreetype.xcframework'
png_framework_path='/Users/evgenij/Developer/Xcode projects/LibPNG/Binaries/png.xcframework'
platforms_path='/Applications/Xcode.app/Contents/Developer/Platforms'
# Your signing identity to sign the xcframework. Execute "security find-identity -v -p codesigning" and select one from the list
identity=070BA25D98F2A17A61E3E27E31BE64C06F901016

# HarfBuzz source code folder
source_name="harfbuzz-14.2.0"
cd $source_name


# Create the build directory if not exists
mkdir -p build-apple


# Remove logs if exist
rm -f "build-apple/log.txt"


make_pkg_config() {
  local name=$1
  local libname=$2
  local config_name=$3
  local prefix=${4}

  echo $prefix

  mkdir -p build-apple/$config_name/pkg-config
  rm -f   "build-apple/$config_name/pkg-config/$name.pc"
  # idk wtf meson.build expects freetype version to be at least 12.0.6 when the latest official version is 2.13.3, so we just define our own version
  echo \
"prefix=${prefix}
exec_prefix=\${prefix}
libdir=\${exec_prefix}
includedir=\${prefix}/Headers 

Name: $name
Description: some description
Version: 1000.0.0
Libs: -L\${libdir} -l$libname
Cflags: -I\"\${includedir}\"
" \
>> "build-apple/$config_name/pkg-config/$name.pc"
  exit_if_error
}


# Compile the library for specific OS and architecture
build_library() {
  local platform_name=$1
  local arch=$2
  local target_os=$3

  # Determine config name
  local config_name="$platform_name/$arch"

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
  rm -rf build-apple/$config_name
  exit_if_error

  # Welcome message
  echo "Build for ${bold}$config_name${normal}"
  mkdir -p build-apple/$config_name

  # Remove config file if exists
  rm -f "build-apple/$config_name.txt"
  exit_if_error

  # Generate meson config file for cross-compile
  echo \
"[binaries]
c = 'clang'
cpp = 'clang++'
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
c_link_args = ['-arch', '$arch', '-mtargetos=$target_os']
cpp_link_args = ['-arch', '$arch', '-mtargetos=$target_os']" \
>> "build-apple/$config_name.txt"
  exit_if_error


  # Create custom pkg-config file for freetype to target specific platform and architecture
  mkdir -p build-apple/$config_name/
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
#   local freetype_path="$freetype_framework_path/$framework_target"
#   mkdir -p build-apple/$config_name/pkg-config
#   rm -f   "build-apple/$config_name/pkg-config/freetype2.pc"
#   # idk wtf meson.build expects freetype version to be at least 12.0.6 when the latest official version is 2.13.3, so we just define our own version
#   echo \
# "prefix=\"$freetype_path\"
# exec_prefix=\${prefix}
# libdir=\${exec_prefix}
# includedir=\${prefix}/Headers 

# Name: FreeType 2
# Description: A free, high-quality, and portable font engine.
# Version: 1000.0.0
# Requires: zlib, bzip2
# Libs: -L\${libdir} -llibfreetype
# Libs.private: -lz
# Cflags: -I\"\${includedir}\"
# " \
# >> "build-apple/$config_name/pkg-config/freetype2.pc"
  # exit_if_error

  #local freetype_path="$freetype_framework_path/$framework_target"
  #make_pkg_config freetype2 libfreetype $config_name \"$freetype_path\"

  local png_path="$png_framework_path/$framework_target"
  echo ${png_path}
  make_pkg_config libpng libpng16 $config_name "${png_path}"
  
  # Setup meson build
  echo "Configure meson"
  meson setup build-apple/$config_name \
    --cross-file build-apple/$config_name.txt \
    --prefix=$(pwd)/build-apple/$config_name/install \
    --strip \
    -Dpkg_config_path="$(pwd)/build-apple/$config_name/pkg-config" \
    -Dcpp_std=c++20 \
    -Ddefault_library=static \
    -Dicu=disabled \
    -Dglib=disabled \
    -Dgobject=disabled \
    -Dcairo=disabled \
    -Dchafa=disabled \
    -Dfreetype=disabled \
    -Dpng=enabled \
    -Dgpu=disabled \
    -Dtests=disabled \
    -Dintrospection=disabled \
    -Ddocs=disabled \
    -Dbuildtype=minsize >> build-apple/log.txt
  exit_if_error
  
  # Build
  echo "Build"
  ninja -C build-apple/$config_name >> build-apple/log.txt
  exit_if_error
  
  # Install compiled libraries and headers into the install folder
  ninja -C build-apple/$config_name install >> build-apple/log.txt
  exit_if_error

  # cairo, gobject and subset are not included (maybe for now) - remove those headers to not confuse users
  rm -rf build-apple/$config_name/install/include/harfbuzz/hb-cairo.h
  rm -rf build-apple/$config_name/install/include/harfbuzz/hb-gobject.h
  rm -rf build-apple/$config_name/install/include/harfbuzz/hb-gobject-enums.h
  rm -rf build-apple/$config_name/install/include/harfbuzz/hb-gobject-structs.h
  rm -rf build-apple/$config_name/install/include/harfbuzz/hb-subset.h
  rm -rf build-apple/$config_name/install/include/harfbuzz/hb-subset-serialize.h
  
  # Does not work anymore
  # Without module.modulemap HarfBuzz is not exposed to Swift
  # Copy the module map into the directory with installed header files
  # mkdir -p build-apple/$config_name/install/include/harfbuzz/HarfBuzz-Module  
  # cp module.modulemap build-apple/$config_name/install/include/harfbuzz/HarfBuzz-Module/module.modulemap
  # exit_if_error
  
  # Strip installed library
  strip -S build-apple/$config_name/install/lib/libharfbuzz.a >> build-apple/log.txt
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
  # Remove previously created framework if exists
  rm -rf build-apple/libharfbuzz.xcframework
  exit_if_error

  # Merge macOS arm and x86 binaries
  mkdir -p build-apple/MacOSX
  exit_if_error
  lipo -create -output build-apple/MacOSX/libharfbuzz.a \
    build-apple/MacOSX/arm64/install/lib/libharfbuzz.a \
    build-apple/MacOSX/x86_64/install/lib/libharfbuzz.a
  exit_if_error

  # Merge iOS simulator arm and x86 binaries
  mkdir -p build-apple/iPhoneSimulator
  exit_if_error
  lipo -create -output build-apple/iPhoneSimulator/libharfbuzz.a \
    build-apple/iPhoneSimulator/arm64/install/lib/libharfbuzz.a \
    build-apple/iPhoneSimulator/x86_64/install/lib/libharfbuzz.a
  exit_if_error

  # Merge tvOS simulator arm and x86 binaries
  mkdir -p build-apple/AppleTVSimulator
  exit_if_error
  lipo -create -output build-apple/AppleTVSimulator/libharfbuzz.a \
    build-apple/AppleTVSimulator/arm64/install/lib/libharfbuzz.a \
    build-apple/AppleTVSimulator/x86_64/install/lib/libharfbuzz.a
  exit_if_error

  # Merge watchOS simulator arm and x86 binaries
  mkdir -p build-apple/WatchSimulator
  exit_if_error
  lipo -create -output build-apple/WatchSimulator/libharfbuzz.a \
    build-apple/WatchSimulator/arm64/install/lib/libharfbuzz.a \
    build-apple/WatchSimulator/x86_64/install/lib/libharfbuzz.a
  exit_if_error

  # Merge visionOS simulator arm and x86 binaries
  mkdir -p build-apple/XRSimulator
  exit_if_error
  lipo -create -output build-apple/XRSimulator/libharfbuzz.a \
    build-apple/XRSimulator/arm64/install/lib/libharfbuzz.a \
    build-apple/XRSimulator/x86_64/install/lib/libharfbuzz.a
  exit_if_error

  # Create the framework with multiple platforms
  xcodebuild -create-xcframework \
    -library build-apple/MacOSX/libharfbuzz.a                      -headers build-apple/MacOSX/arm64/install/include/harfbuzz \
    -library build-apple/iPhoneOS/arm64/install/lib/libharfbuzz.a  -headers build-apple/iPhoneOS/arm64/install/include/harfbuzz \
    -library build-apple/iPhoneSimulator/libharfbuzz.a             -headers build-apple/iPhoneSimulator/arm64/install/include/harfbuzz \
    -library build-apple/AppleTVOS/arm64/install/lib/libharfbuzz.a -headers build-apple/AppleTVOS/arm64/install/include/harfbuzz \
    -library build-apple/AppleTVSimulator/libharfbuzz.a            -headers build-apple/AppleTVSimulator/arm64/install/include/harfbuzz \
    -library build-apple/WatchOS/arm64/install/lib/libharfbuzz.a   -headers build-apple/WatchOS/arm64/install/include/harfbuzz \
    -library build-apple/WatchSimulator/libharfbuzz.a              -headers build-apple/WatchSimulator/arm64/install/include/harfbuzz \
    -library build-apple/XROS/arm64/install/lib/libharfbuzz.a      -headers build-apple/XROS/arm64/install/include/harfbuzz \
    -library build-apple/XRSimulator/libharfbuzz.a                 -headers build-apple/XRSimulator/arm64/install/include/harfbuzz \
    -output build-apple/libharfbuzz.xcframework
  exit_if_error

  # And sign the framework
  codesign --timestamp -s $identity build-apple/libharfbuzz.xcframework
  exit_if_error
}
create_framework







# 8===o