#!/bin/bash
# macOS-config by DESIGNØ®
# This Software is copyright DESIGNØ®, all rights reserved.
# Copyright © 2024 DESIGNØ SASU.
<<LICENSE
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
LICENSE

VERSION=1.0.0
set -u

# string formatters
if [[ -t 1 ]]; then
    tty_escape(){ printf "\033[%sm" "$1"; }
else
    tty_escape(){ :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_red="$(tty_mkbold 31)"
tty_green="$(tty_mkbold 32)"
tty_blue="$(tty_mkbold 34)"
tty_rose="$(tty_mkbold 35)"
tty_tur="$(tty_mkbold 36)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join(){
    local arg
    printf "%s" "$1"
    shift
    for arg in "$@"
    do
        printf " "
        printf "%s" "${arg// /\ }"
    done
}
chomp(){
    printf "%s" "${1/"$'\n'"/}"
}
ohai(){
    printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}
warn(){
    printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}
notice(){
    printf "${tty_rose}Notice${tty_reset}: %s\n" "$(chomp "$1")"
}
complete(){
    printf "${tty_green}Success${tty_reset}: %s\n" "$(chomp ${tty_bold}"$1"${tty_reset})"
    echo
    exit 0
}

abort(){
  warn "$@" >&2
  exit 1
}

#OS check
OS="$(uname)"
# if [[ "${OS}" == "Linux" ]]; then
#    INSTALL_ON_LINUX=1
if [[ "${OS}" == "Darwin" ]]; then
    INSTALL_ON_MACOS=1
else
    abort "macOS config should only run on macOS."
fi

brew_update(){
    if [ "$(command -v brew)" ]; then
        warn "Homebrew already exists"
        ohai "Updating Homebrew..."
        brew update
    else
        echo "Installing Hombrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        # For silicon macs:
        echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.zshrc
        source ~/.zshrc
    fi
}

brew_install(){
    if brew list $1 >/dev/null 2>&1; then
        notice "${1} is already installed"
        brew_upgrade ${1}
    else
        echo "Installing ${1}..."
        brew install ${1}
    fi
}

brew_install_cask(){
    if brew list --cask $1 >/dev/null 2>&1; then
        notice "${1} is already installed"
        brew_upgrade_cask ${1}
    else
        echo "Installing ${1}..."
        brew install --cask ${1}
    fi
}

brew_upgrade(){
    if brew outdated $1 >/dev/null 2>&1; then
        echo "formula is up to date"
    else
        warn "formula is outdated\n"
        ohai "Upgrading formula..."
        brew upgrade ${1}
        ohai "Cleaning up..."
        brew cleanup ${1}
    fi
}

brew_upgrade_cask(){
    if brew outdated --cask $1 >/dev/null 2>&1; then
        echo "Cask is up to date"
    else
        warn "Cask is outdated\n"
        ohai "Upgrading formula..."
        brew upgrade --cask ${1}
        ohai "Cleaning up..."
        brew cleanup --cask ${1}
    fi
}

cflags_dir(){
    gtk_version="$(brew list --versions | grep ${1} | cut -d " " -f 2)"
    cd /usr/local/Cellar/gtkmm3/$gtk_version/lib/pkgconfig && pkg-config gtkmm-3.0.pc --cflags --libs
}

to_dir(){ cd $1; }

getc(){
  local save_state
  save_state="$(/bin/stty -g)"
  /bin/stty raw -echo
  IFS='' read -r -n 1 -d '' "$@"
  /bin/stty "${save_state}"
}

wait_4_skip(){
    local r=1
    echo
    echo "Press ${tty_bold}RETURN${tty_reset}/${tty_bold}ENTER${tty_reset} if you wish to install ${tty_bold}$1${tty_reset} or press any other key to ${tty_bold}skip${tty_reset} this step:"
    local c
    getc c
    # we test for \r and \n because some stuff does \r instead
    if [[ "${c}" == $'\r' || "${c}" == $'\n' ]]; then
        r=0
    fi
    return $r
}

main(){
    local s
    # Install or update HomeBrew
    brew_update
    
    # Install Xcode Toolchain
    # Check if Xcode Command Line Tools are installed
    if ! command -v xcode-select >/dev/null; then
        echo "Xcode Command Line Tools are not installed. Installing..."
        xcode-select --install
    else
        echo "Xcode Command Line Tools are already installed."
    fi

    # Install python
    wait_4_skip "python"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install python3
    fi
    
    # Install node.js
    wait_4_skip "node.js"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install nvm
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
        source ~/.zshrc
        nvm install --lts
    fi

    # Install openssl
    wait_4_skip "openssl"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install openssl@1.1
    fi

    # Install mongodb
    wait_4_skip "mongodb"
    s=$?
    if [ $s -eq 0 ]; then
        brew tap mongodb/brew
        brew_install mongodb-community@7.0
    fi

    # Install Zoom
    wait_4_skip "Zoom"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask zoom
    fi

    # End of setup
    complete "MacOS setup completed"
}

main "$@"

#
# Links
#
# DEPRECATED INSTALLATION METHODS:
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#
#!EOF
