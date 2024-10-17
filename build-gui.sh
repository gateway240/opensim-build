#!/bin/bash

# Exit on error
set -e

# Default values for flags.
DEBUG_TYPE="Release"
NUM_JOBS=$(nproc)
GUI_BRANCH="main"

# Get opensim-gui.
echo "LOG: CLONING OPENSIM-GUI..."
git -C ~/opensim-workspace/opensim-gui-source pull || git clone https://github.com/opensim-org/opensim-gui.git ~/opensim-workspace/opensim-gui-source
cd ~/opensim-workspace/opensim-gui-source
git checkout $GUI_BRANCH
git submodule update --init --recursive -- opensim-models opensim-visualizer Gui/opensim/threejs
echo

# Build opensim-gui.
echo "LOG: BUILDING OPENSIM-GUI..."
mkdir -p ~/opensim-workspace/opensim-gui-build || true
cd ~/opensim-workspace/opensim-gui-build
cmake ~/opensim-workspace/opensim-gui-source \
    -DCMAKE_PREFIX_PATH=~/opensim-core \
    -DAnt_EXECUTABLE=~/netbeans-12.3/netbeans/extide/ant/bin/ant \
    -DANT_ARGS="-Dnbplatform.default.netbeans.dest.dir=$HOME/netbeans-12.3/netbeans;-Dnbplatform.default.harness.dir=$HOME/netbeans-12.3/netbeans/harness"
make CopyOpenSimCore -j$NUM_JOBS
make PrepareInstaller -j$NUM_JOBS
echo

Install opensim-gui.
echo "LOG: INSTALLING OPENSIM-GUI..."
cd ~/opensim-workspace/opensim-gui-source/Gui/opensim/dist/installer/opensim
bash INSTALL
echo
