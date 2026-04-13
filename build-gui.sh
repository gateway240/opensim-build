#!/bin/bash

# Exit on error
set -e

# Default values for flags.
DEBUG_TYPE="Release"
NUM_JOBS=$(nproc)
GUI_BRANCH="main"

ROOT=$HOME/opensim-workspace/opensim-gui-build
# Get opensim-gui.
echo "LOG: CLONING OPENSIM-GUI..."
git -C ~/opensim-workspace/opensim-gui-source pull || git clone git@github.com:gateway240/opensim-gui.git ~/opensim-workspace/opensim-gui-source
cd ~/opensim-workspace/opensim-gui-source
# git checkout $GUI_BRANCH
git submodule update --init --recursive --remote

# Build opensim-gui.
echo "LOG: BUILDING OPENSIM-GUI..."
mkdir -p $ROOT || true
cd $ROOT
cmake ~/opensim-workspace/opensim-gui-source \
    -DCMAKE_PREFIX_PATH=$HOME/opensim-core \
    -DAnt_EXECUTABLE=$HOME/netbeans/extide/ant/bin/ant \
    -DANT_ARGS="-Dnbplatform.default.netbeans.dest.dir=$HOME/netbeans;-Dnbplatform.default.harness.dir=$HOME/netbeans/harness"
make CopyOpenSimCore -j$NUM_JOBS
make PrepareInstaller -j$NUM_JOBS
echo

# Add jxbrowser files to installer content
# Set root and directories
NBM_DIR="$ROOT/prebuilt_jxb"
EXTRACT_DIR="$NBM_DIR/extracted"
INSTALLER_CONTENT="$ROOT/Gui/opensim/dist/installer/opensim/opensim"

# Create prebuilt directory
mkdir -p "$NBM_DIR"

# Download the NBM file pinned to version v4.6.0
wget -O "$NBM_DIR/org-opensim-javabrowser.nbm" \
        "https://github.com/opensim-org/opensim-visualizer/releases/download/v4.6.0/org-opensim-javabrowser.nbm"

# Extract the NBM (nbm is a zip)
mkdir -p "$EXTRACT_DIR"
unzip -o "$NBM_DIR/org-opensim-javabrowser.nbm" -d "$EXTRACT_DIR"

# Create installer modules directories
mkdir -p "$INSTALLER_CONTENT/modules/"
mkdir -p "$INSTALLER_CONTENT/modules/ext/"

# Copy the main JAR
cp "$EXTRACT_DIR/netbeans/modules/org-opensim-javabrowser.jar" "$INSTALLER_CONTENT/modules/"

# For Linux, copy all JARs with exact names
cp "$EXTRACT_DIR/netbeans/modules/ext/jxbrowser-7.44.1.jar" "$INSTALLER_CONTENT/modules/ext/"
cp "$EXTRACT_DIR/netbeans/modules/ext/jxbrowser-swing-7.44.1.jar" "$INSTALLER_CONTENT/modules/ext/"
cp "$EXTRACT_DIR/netbeans/modules/ext/jxbrowser-linux64-7.44.1.jar" "$INSTALLER_CONTENT/modules/ext/"

# Verify files copied
echo "JAR files now in installer content:"
find "$INSTALLER_CONTENT" -name "*.jar"

# Install opensim-gui.
# echo "LOG: INSTALLING OPENSIM-GUI..."
# cd ~/opensim-workspace/opensim-gui-source/Gui/opensim/dist/installer/opensim
# bash INSTALL
# echo
