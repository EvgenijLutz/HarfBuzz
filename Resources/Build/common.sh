# Common helpers

echo "hello handsome"

test() {
	echo "test"
}

# Console output formatting
# https://stackoverflow.com/a/2924755
bold=$(tput bold)
normal=$(tput sgr0)


# Checks if the path exists
assert_path() {
  local path=$1
  if [ ! -d "$path" ]; then
    echo "$path does not exist. Check if the path correct and try again."
    exit 1
  fi
}


# Checks if an error happened recently and terminates if it's true
exit_if_error() {
  local result=$?
  if [ $result -ne 0 ] ; then
     echo "Received an exit code $result, aborting"
     exit 1
  fi
}


# Sets the "framework_target" variable - etermine framework target folder name based on
# platform ("MacOSX", "iPhoneOS", "iPhoneSimulator" and so on) and architecture ("x86_64" or "arm64")
set_framework_target_var() {
  local platform_name=$1
  local arch=$2

  if [[ "$platform_name" == "MacOSX" ]]; then
    framework_target="macos-arm64_x86_64"
  elif [[ "$platform_name" == "iPhoneOS" ]]; then
    framework_target="ios-$arch"
  elif [[ "$platform_name" == "iPhoneSimulator" ]]; then
    framework_target="ios-arm64_x86_64-simulator"
  elif [[ "$platform_name" == "AppleTVOS" ]]; then
    framework_target="tvos-$arch"
  elif [[ "$platform_name" == "AppleTVSimulator" ]]; then
    framework_target="tvos-arm64_x86_64-simulator"
  elif [[ "$platform_name" == "WatchOS" ]]; then
    framework_target="watchos-$arch"
  elif [[ "$platform_name" == "WatchSimulator" ]]; then
    framework_target="watchos-arm64_x86_64-simulator"
  elif [[ "$platform_name" == "XROS" ]]; then
    framework_target="xros-$arch"
  elif [[ "$platform_name" == "XRSimulator" ]]; then
    framework_target="xros-arm64_x86_64-simulator"
  else
    echo "Unknown platform $platform_name"
    exit 1
  fi
}