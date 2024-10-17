# opensim-build

Building from the source code
-----------------------------

**NOTE**: On all platforms (Windows, OSX, Linux), you should
build all OpenSim dependencies (Simbody, etc) with the
same *CMAKE_BUILD_TYPE* (Linux) / *CONFIGURATION*
(MSVC/Xcode) (e.g., Release, Debug) as OpenSim. Failing to
do so *may* result in mysterious runtime errors like
segfaults.


## Arch Linux Platform Dependencies

1. Install platform specific dependencies from pacman
```
sudo pacman -S base-devel cmake autoconf pkg-config automake blas lapack freeglut libxi libxmu doxygen python3 python-numpy git openssl pcre pcre2 libtool gcc-fortran ninja patchelf byacc bison glu jdk8-openjdk
```

2. Install this specific outdated version of SWIG (4.1.1):

```bash 
sudo pacman -U https://archive.archlinux.org/packages/s/swig/swig-4.1.1-2-x86_64.pkg.tar.zst
```

> NOTE: If you run `sudo pacman -Syu` it will update the SWIG version so you'll have to run the command again to revert to the older version

3. Install Netbeans 12.3
```bash 
mkdir -p ~/opensim-workspace/Netbeans12.3 || true && cd ~/opensim-workspace/Netbeans12.3
wget -nc -q --show-progress https://archive.apache.org/dist/netbeans/netbeans/12.3/Apache-NetBeans-12.3-bin-linux-x64.sh
chmod 755 Apache-NetBeans-12.3-bin-linux-x64.sh
./Apache-NetBeans-12.3-bin-linux-x64.sh
```

## Ubuntu Platform Dependencies
For now follow opensim build instructions 1

// TODO

## Building on any Unix-Based Distribution (Ubuntu, Arch, Mac, NOT Windows)

1. Install platform dependencies first!

2. Build opensim-core by running `build-core.sh`. Add `-n` flag if you have and want to use Ninja instead of Makefiles

3. On first install you will need to add opensim-core to your path or symlink it to somewhere already on the path.
Note that this script will ask for sudo so it is a good idea to inspect it's contents before running.
This script will symlink opensim-core to `usr/local/bin` which should be on your path:
```bash
~/opensim-core/bin/opensim-install-command-line.sh
```

4. Optionally build the gui with `build-gui.sh` (you will need to build the core with java bindings)


# Reference OpenSim Documentation

- [Build Instructions 1](https://github.com/opensim-org/opensim-core/wiki/Build-Instructions) - Github
- [Build Instructions 2](https://opensimconfluence.atlassian.net/wiki/spaces/OpenSim/pages/53089260/Building+OpenSim+from+Source) - Confluence
- [Build Instructions 3](https://github.com/opensim-org/opensim-core/wiki/Build-Instructions-(Old-deprecated)) - Deprecated
- [Build Instructions 4](https://opensimconfluence.atlassian.net/wiki/spaces/OpenSim/pages/53089315/Building+the+GUI) - GUI
- [Build Instructions 5](https://opensimconfluence.atlassian.net/wiki/spaces/OpenSim/pages/53089353/Building+GUI+Installer) - GUI Installer
- [Build Instructions 6](https://opensimconfluence.atlassian.net/wiki/spaces/OpenSim/pages/53089331/Guide+to+Building+Doxygen) - Doxygen
- [Build Instructions 7](https://opensimconfluence.atlassian.net/wiki/spaces/OpenSim/pages/53114400/Linux+Support) - Linux Support
- [Confluence Build C++ Example](https://opensimconfluence.atlassian.net/wiki/spaces/OpenSim/pages/53088864/How+to+Build+a+C+Example)

- [Code Standards](https://opensimconfluence.atlassian.net/wiki/spaces/OpenSim/pages/53089338/OpenSim+Coding+Standards)

