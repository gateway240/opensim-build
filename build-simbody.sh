#!/bin/bash

# Exit on error
set -e

# Default values for flags.
DEBUG_TYPE="RelWithDebInfo"
NUM_JOBS=$(nproc)
MOCO="on"
CORE_BRANCH="master"
GENERATOR="Unix Makefiles"

Help() {
  echo
  echo "This script builds and installs the last available version of OpenSim-Core in your computer."
  echo "Usage: ./scriptName [OPTION]..."
  echo "Example: ./opensim-core-build.sh -j 4 -d \"Release\""
  echo "    -d         Debug Type. Available Options:"
  echo "                   Release (Default): No debugger symbols. Optimized."
  echo "                   Debug: Debugger symbols. No optimizations (>10x slower). Library names ending with _d."
  echo "                   RelWithDefInfo: Debugger symbols. Optimized. Bigger than Release, but not slower."
  echo "                   MinSizeRel: No debugger symbols. Minimum size. Optimized."
  echo "    -j         Number of jobs to use when building libraries (>=1)."
  echo "    -s         Simple build without moco (Tropter and Casadi disabled)."
  echo "    -c         Branch for opensim-core repository."
  echo "    -n         Use the Ninja generator to build opensim-core. If not set, Unix Makefiles is used."
  echo
  exit
}

# Get flag values if any.
while getopts 'j:d:s:c:n' flag; do
  case "${flag}" in
  j) NUM_JOBS=${OPTARG} ;;
  d) DEBUG_TYPE=${OPTARG} ;;
  s) MOCO="off" ;;
  c) CORE_BRANCH=${OPTARG} ;;
  n) GENERATOR="Ninja" ;;
  *) Help ;;
  esac
done

# Check if parameters are valid.
if [[ $NUM_JOBS -lt 1 ]]; then
  Help
fi
if [[ $DEBUG_TYPE != "Release" ]] && [[ $DEBUG_TYPE != "Debug" ]] && [[ $DEBUG_TYPE != "RelWithDebInfo" ]] && [[ $DEBUG_TYPE != "MinSizeRel" ]]; then
  Help
fi

# Show values of flags:
echo
echo "Build script parameters:"
echo "DEBUG_TYPE="$DEBUG_TYPE
echo "NUM_JOBS="$NUM_JOBS
echo "MOCO="$MOCO
echo "CORE_BRANCH="$CORE_BRANCH
echo "GENERATOR="$GENERATOR
echo ""

# Check OS.
echo "LOG: CHECKING OS..."
# found this here https://unix.stackexchange.com/a/25131
OS_NAME=$(cat /etc/os-release)
echo "OS="$OS_NAME
echo ""

# Get simbody
echo "LOG: CLONING SIMBODY..."
git -C ~/opensim-workspace/simbody-source pull ||
git clone git@github.com:gateway240/simbody.git ~/opensim-workspace/simbody-source
cd ~/opensim-workspace/simbody-source
# Ignore the git checkout error if you can't check something out
git checkout $CORE_BRANCH || true
echo


# Build simbody
echo "LOG: BUILDING SIMBODY..."
mkdir -p ~/opensim-workspace/simbody-build || true
cd ~/opensim-workspace/simbody-build
cmake ~/opensim-workspace/simbody-source \
  -G"$GENERATOR" \
  \
  -DCMAKE_INSTALL_PREFIX=~/simbody \
  -DCMAKE_CXX_FLAGS="-march=native ${CMAKE_CXX_FLAGS}" \
  -DCMAKE_BUILD_TYPE=$DEBUG_TYPE
cmake . -LAH
cmake --build .  -j$NUM_JOBS
echo

# Install opensim-core.
echo "LOG: INSTALL SIMBODY..."
cd ~/opensim-workspace/simbody-build
cmake --install .
