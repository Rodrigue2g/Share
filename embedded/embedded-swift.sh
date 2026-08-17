#!bin/bash

# If you haven't already, install Homebrew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then Start by downloading Swiftly to Install and manage your Swift
$ brew install swiftly

# Now run swiftly init to finish the installation
$ swiftly init

# You can then install the latest (stable) version of the toolchain
$ swiftly install latest

# And check the version (optional)
$ swift --version

# Then you should locate the toolchain
$ ls ~/Library/Developer/Toolchains/
# swift-6.2-RELEASE.xctoolchain swift-latest.xctoolchain ... <Any other toolchain you have installed>

# Find the toolchain identifier
$ plutil -extract CFBundleIdentifier raw \
  -o - \
  ~/Library/Developer/Toolchains/swift-latest.xctoolchain/Info.plist
# org.swift.6200202509111a

# Test the toolchain
$ TOOLCHAINS=org.swift.6200202509111a swift --version
# Apple Swift version 5.10 (swiftlang-5.10.0.13 clang-1500.3.9.4)
# Target: x86_64-apple-darwin23.4.0

# Install CMake, Ninja, and dfu-util
$ brew install cmake ninja dfu-util

# Create an ESP SDK directory
$ mkdir -p ~/esp

# Download the ESP-IDF SDK
$ cd ~/esp
$ git clone \
  --branch v5.2.1 \
  --depth 1 \
  --shallow-submodules \
  --recursive https://github.com/espressif/esp-idf.git \
  --jobs 24

# Install the ESP-IDF SDK
$ cd ~/esp/esp-idf
$ ./install.sh

# Download the ESP-Matter SDK
$ cd ~/esp
$ git clone \
    --branch release/v1.2 \
    --depth 1 \
    --shallow-submodules \
    --recursive https://github.com/espressif/esp-matter.git \
    --jobs 24

# Install the ESP-Matter SDK
$ cd ~/esp/esp-matter
$ ./install.sh

###
# ! The following should be done in the shell where you plan to build your project !
# It has to be redone every time you open a new shell.
##
# Setup the Swift nightly toolchain
$ export TOOLCHAINS=org.swift.6200202509111a

# Setup the ESP-IDF environment
$ . ~/esp/esp-idf/export.sh

# Setup the ESP-Matter environment
$ . ~/esp/esp-matter/export.sh

# You can then test your installation by runing:
$ idf.py --list-targets

# And prevent potential bugs from arising during build time by runing:
$ idf.py add-dependency "espressif/esp_diag_data_store==1.0.1"
