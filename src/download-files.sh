#!/bin/bash

set -e

cd "$(dirname "$0")/.."

# Directory where you want the files to be dowloaded
DATA_DIR="../data"
mkdir -p "$DATA_DIR"

# List the files you want to download here
BASE_URL="https://snap.stanford.edu/data"
FILES=(
  "web-redditEmbeddings-users.csv"
  "web-redditEmbeddings-subreddits.csv"
)

OS="$(uname)"
if [[ "${OS}" == "Linux" ]]; then
    INSTALL_ON_LINUX=1
elif [[ "${OS}" == "Darwin" ]]; then
    INSTALL_ON_MACOS=1
else
    echo "Install Script written for macOS or Linux only."
    exit 1
fi

if command -v wget >/dev/null 2>&1; then
    DL_CMD="wget -q --show-progress"
# elif command -v curl >/dev/null 2>&1; then # curl doesn't actually work -- unable to unpack tsv
#     DL_CMD="curl -L -o"
else
    if [[ "$INSTALL_ON_MACOS" == 1 ]]; then
        if [ "$(command -v brew)" ]; then
            echo "Installing wget..."
            brew install wget 
        else
            echo "❌ Install Homebrew first: https://brew.sh/"
            exit 1
        fi
    else
        echo "❌ No wget or curl found. Please install one."
        exit 1
    fi
fi

echo "Downloading datasets..."

for file in "${FILES[@]}"; do
  url="$BASE_URL/$file"
  echo "Fetching $file"
  if [[ "$DL_CMD" =~ wget ]]; then
      wget -q --show-progress "$url" -O "$DATA_DIR/$file"
  else
      curl -L "$url" -o "$DATA_DIR/$file"
  fi
done

echo "✅ All downloads complete. Files saved to $DATA_DIR"
