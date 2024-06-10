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

VERSION=1.4.0
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

#Architecture check
arch="$(uname -m)"
if [ "$arch" = "arm64" ]; then
    #echo "ARM64 architecture (Apple Silicon)."
    :
elif [ "$arch" = "x86_64" ]; then
    #echo "x86_64 architecture (Intel)."
    :
else
    abort "Unknown architecture: $arch"
fi

brew_update(){
    if [ "$(command -v brew)" ]; then
        warn "Homebrew already exists"
        ohai "Updating Homebrew..."
        brew update
    else
        echo "Installing Hombrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

formulas=("python", "pythonPKG","nodejs", "openssl", "mongodb", "java", "ngrok", )
casks=("zoom", "webex","slack", "github", "vsc", "docker", "vbox", "vmware", "wireshark", "mongoDBCompass", "SFSymbols", "ltspice", "kikad", "arduino", "telegram", "messenger", "whatsapp", "spotify", "chrome", "drive", "word", "powerpoint", "excel", "logitechoptionsplus", "texshop",)

fchoices=()
cchoices=()

fastForward(){
    local r=1
    echo
    echo "Press ${tty_bold}RETURN${tty_reset}/${tty_bold}ENTER${tty_reset} if you want to proceed ${tty_bold}Step by Step{tty_reset} or press any other key to ${tty_bold}fastforward${tty_reset} the installation process."
    local c
    getc c
    # we test for \r and \n because some stuff does \r instead
    if [[ "${c}" == $'\r' || "${c}" == $'\n' ]]; then
        r=0
    fi
    if [ $r -eq 0 ]; then
        return
    fi
    
    # Start by selecting formulas
    printf "\n${tty_rose}Select the formulas you wish to install:${tty_reset}%s\n"
    
    for formula in "${formulas[@]}"; do
        while true; do
            read -p "Download $formula? [y/n]: " choice
            case "$choice" in
                y|Y )
                    fchoices+=("$formula")
                    break
                    ;;
                n|N )
                    break
                    ;;
                * )
                    echo "Please answer y or n."
                    ;;
            esac
        done
    done

    # Then select casks
    printf "\n${tty_rose}Select the casks you wish to install:${tty_reset}%s\n"

    for cask in "${casks[@]}"; do
        while true; do
            read -p "Download $cask? [y/n]: " choice
            case "$choice" in
                y|Y )
                    cchoices+=("$cask")
                    break
                    ;;
                n|N )
                    break
                    ;;
                * )
                    echo "Please answer y or n."
                    ;;
            esac
        done
    done

    echo "You have chosen to download the following formulas: ${fchoices[@]}"
    echo
    echo "And the following casks: ${cchoices[@]}"

    # End of setup
    echo
    complete "MacOS setup completed"
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

    fastForward

    # Start by installing formulas
    printf "\n${tty_rose}Begining to install formulas:${tty_reset}%s\n"

    # Install python with miniconda
    wait_4_skip "python with miniconda"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask miniconda 
        conda install python  # Better for jupyter notebooks and virtual env 
        # brew_install python3  -- Not a good way to install python --
        pip install --upgrade pip
    fi

    # Install python packages
    wait_4_skip "Commons python packages"
    s=$?
    if [ $s -eq 0 ]; then
        pip install numpy
        pip install pandas
        pip install matplotlib
        pip install scipy
    fi
    
    # Install node.js
    wait_4_skip "node.js"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install nvm
        NVM_PATH="$(brew --prefix nvm)/nvm.sh"
        sudo echo 'export NVM_DIR="$HOME/.nvm"' >> /etc/zshrc
        sudo echo '. "${NVM_PATH}"' >> /etc/zshrc
        source /etc/zshrc
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

    # Install java
    wait_4_skip "java"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install java
    fi

    # Install ngrok
    wait_4_skip "ngrok"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install ngrok/ngrok/ngrok
    fi

    # Move on to casks
    printf "\n${tty_rose}Now installing casks (GUI Applications):${tty_reset}%s\n"

    # Install Zoom
    wait_4_skip "Zoom"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask zoom
    fi

    # Install Webex
    wait_4_skip "Webex"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask webex
    fi

    # Install Slack
    wait_4_skip "Slack"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask slack
    fi

    # Install GitHub Desktop
    wait_4_skip "GitHub Desktop"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask github
    fi

    # Install VSCode
    wait_4_skip "VS Code (Microsoft Visual Studio Code)"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask visual-studio-code
    fi

    # Install Docker
    wait_4_skip "Docker"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask docker
    fi

    # Install Virtual Box
    wait_4_skip "Virtual Box"
    s=$?
    if [ $s -eq 0 ]; then
        if [ "$arch" = "arm64" ]; then
            warn "Virtual Box is only available for x86 architectures"
        elif [ "$arch" = "x86_64" ]; then
            brew_install_cask virtualbox
        fi
    fi

    # Install VMware Horizon Client
    wait_4_skip "VMware Horizon Client"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask vmware-horizon-client
    fi

    # Install Wireshark
    wait_4_skip "Wireshark"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask wireshark
    fi

    # Install MongoDB Compass
    wait_4_skip "MongoDB Compass"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask mongodb-compass
    fi

    # Install SF Symbols
    wait_4_skip "SF Symbols"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask sf-symbols
    fi

    # Install LTSpice
    wait_4_skip "LTSpice"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask ltspice
    fi

    # Install KiCad
    wait_4_skip "KiCad"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask kicad
    fi
    
    # Install Arduino
    wait_4_skip "Arduino (IDE)"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask arduino-ide
    fi

    # Install Telegram
    wait_4_skip "Telegram"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask telegram
    fi

    # Install Messenger
    wait_4_skip "Facebook (Meta) Messenger"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask messenger
    fi

    # Install Whatsapp
    wait_4_skip "Whatsapp"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask whatsapp
    fi

    # Install Spotify
    wait_4_skip "Spotify"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask spotify
    fi

    # Install Google Chrome
    wait_4_skip "Google Chrome"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask google-chrome
    fi

    # Install Google Drive
    wait_4_skip "Google Drive"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask google-drive
    fi

    # Install Microsoft Word
    wait_4_skip "Microsoft Word"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask microsoft-word
    fi

    # Install Microsoft PowerPoint
    wait_4_skip "Microsoft PowerPoint"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask microsoft-powerpoint
    fi

    # Install Microsoft Excel
    wait_4_skip "Microsoft Excel"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask microsoft-excel
    fi

    # Install Logitech Options+
    wait_4_skip "Logitech Options+"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask logi-options-plus
    fi

    # Install TexShop
    wait_4_skip "TexShop (LaTex editor)"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask texshop
    fi

    # End of setup
    echo
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
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
#
#!EOF
