#!bin/bash

# Locate the toolchain
$ ls ~/Library/Developer/Toolchains/

# Find the toolchain identifier
$ plutil -extract CFBundleIdentifier raw \
  -o - \
  ~/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2024-06-13-a.xctoolchain/Info.plist
# org.swift.59202406131a

# Test the toolchain
$ TOOLCHAINS=org.swift.59202406131a swift --version
# Apple Swift version 5.10 (swiftlang-5.10.0.13 clang-1500.3.9.4)
# Target: x86_64-apple-darwin23.4.0

# Install Homebrew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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


# Setup the Swift nightly toolchain
$ export TOOLCHAINS=org.swift.59202406131a

# Setup the ESP-IDF environment
$ . ~/esp/esp-idf/export.sh

# Setup the ESP-Matter environment
$ . ~/esp/esp-matter/export.sh
