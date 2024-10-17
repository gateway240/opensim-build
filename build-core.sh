#!/bin/bash

# Exit on error
set -e

# Default values for flags.
DEBUG_TYPE="Release"
NUM_JOBS=$(nproc)
MOCO="on"
CORE_BRANCH="main"
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

# Get opensim-core.
echo "LOG: CLONING OPENSIM-CORE..."
git -C ~/opensim-workspace/opensim-core-source pull ||
  git clone https://github.com/opensim-org/opensim-core.git ~/opensim-workspace/opensim-core-source
cd ~/opensim-workspace/opensim-core-source
# Ignore the git checkout error if you can't check something out
git checkout $CORE_BRANCH || true
echo

# Build opensim-core dependencies.
echo "LOG: BUILDING OPENSIM-CORE DEPENDENCIES..."
mkdir -p ~/opensim-workspace/opensim-core-dependencies-build || true
cd ~/opensim-workspace/opensim-core-dependencies-build
cmake ~/opensim-workspace/opensim-core-source/dependencies \
  \
  -DCMAKE_CXX_FLAGS="-march=native ${CMAKE_CXX_FLAGS}" \
  -DGRAPHVIZ_CUSTOM_TARGETS=TRUE \
  -DCMAKE_INSTALL_PREFIX=~/opensim-workspace/opensim-core-dependencies-install/ \
  -DSUPERBUILD_ezc3d=on \
  -DOPENSIM_WITH_CASADI=$MOCO \
  -DOPENSIM_WITH_TROPTER=$MOCO # --graphviz=deps.dot \
# -DCMAKE_CXX_FLAGS=-pg -DCMAKE_EXE_LINKER_FLAGS=-pg -DCMAKE_SHARED_LINKER_FLAGS=-pg

cmake . -LAH
cmake --build . --config $DEBUG_TYPE -j$NUM_JOBS
echo

# Build opensim-core.
echo "LOG: BUILDING OPENSIM-CORE..."
mkdir -p ~/opensim-workspace/opensim-core-build || true
cd ~/opensim-workspace/opensim-core-build
cmake ~/opensim-workspace/opensim-core-source \
  -G"$GENERATOR" \
  -DCMAKE_CXX_FLAGS="-march=native ${CMAKE_CXX_FLAGS}" \
  -DOPENSIM_DEPENDENCIES_DIR=~/opensim-workspace/opensim-core-dependencies-install/ \
  -DBUILD_JAVA_WRAPPING=off \
  -DBUILD_PYTHON_WRAPPING=off \
  -DBUILD_EXAMPLES=off \
  -DBUILD_TESTING=off \
  -DOPENSIM_C3D_PARSER=ezc3d \
  -DCMAKE_INSTALL_PREFIX=~/opensim-core \
  -DOPENSIM_INSTALL_UNIX_FHS=off \
  -DSWIG_DIR=/usr/bin/swig \
  -DSWIG_EXECUTABLE=/usr/bin/swig
  # --graphviz=deps.dot -DGRAPHVIZ_CUSTOM_TARGETS=TRUE \
#  -DCMAKE_CXX_FLAGS=-pg -DCMAKE_EXE_LINKER_FLAGS=-pg -DCMAKE_SHARED_LINKER_FLAGS=-pg
cmake . -LAH
cmake --build . --config $DEBUG_TYPE -j$NUM_JOBS
echo

# Test opensim-core.
echo "LOG: TESTING OPENSIM-CORE..."
# cd ~/opensim-workspace/opensim-core-build
# # TODO: Temporary for python to find Simbody libraries.
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/opensim-workspace/opensim-core-dependencies-install/simbody/lib
# ctest --parallel $NUM_JOBS --output-on-failure

# Install opensim-core.
echo "LOG: INSTALL OPENSIM-CORE..."
cd ~/opensim-workspace/opensim-core-build
cmake --install .
