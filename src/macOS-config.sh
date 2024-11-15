#!/bin/bash
# macOS-config by DESIGNØ®
# This Software is copyright DESIGNØ®, all rights reserved.
# Copyright © 2024 DESIGNØ GROUP LTD.
<<LICENSE
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
LICENSE

VERSION=2.2.0
set -u 
#set +u

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
tty_yellow="$(tty_mkbold 33)"
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
    #printf "%s" "${1//$'\n'/}"
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
    ARCH_ARM64=1
elif [ "$arch" = "x86_64" ]; then
    #echo "x86_64 architecture (Intel)."
    ARCH_X86_64=1
else
    abort "Unknown architecture: $arch"
fi

if [[ $- == *i* ]]; then
    INTERACTIVE_MODE=1
else
    INTERACTIVE_MODE=0
fi

if [[ "$0" == "-zsh" || "$0" == "zsh" ]]; then
    ZSH_SHELL=1
    if [ -z "$VENDOR" ]; then
        export VENDOR="apple"
    fi
    abort "MacOS config currently has issues while runing in zsh. Please use /bin/bash instead."
elif [[ "$0" == "-bash" ]] || [[ "$0" == "bash" ]]; then
    BASH_SHELL=1
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
        if [ "${ARCH_ARM64:-0}" -eq 1 ]; then
            echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.zshrc
            source ~/.zshrc
        fi
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
        brew cleanup ${1}
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

<<WARNING
WARNING
############## This section must be changed very carefully! Each formula/cask MUST have an associated common name (display name) and the ORDER MATTERS! (replica of a dictionary) ##############
formulas=("python" "python-pkg" "nodejs" "openssl@1.1" "mongodb" "java" "ngrok" "git-lfs")
fcn=("Python with miniconda" "Commons python packages" "node.js (with nvm)" "openssl" "mongodb" "java" "ngrok" "Git Large File Storage (lfs)")
casks=("zoom" "webex" "slack" "github" "visual-studio-code" "docker" "virtualbox" "vmware-horizon-client" "wireshark" "mongodb-compass" "sf-symbols" "ltspice" "kicad" "arduino-ide" "telegram" "messenger" "whatsapp" "spotify" "google-chrome" "google-drive" "microsoft-word" "microsoft-powerpoint" "microsoft-excel" "logi-options-plus" "texshop" "sage")
ccn=("Zoom" "Webex" "Slack" "Github Desktop" "VS Code (Microsoft Visual Studio Code)" "Docker" "Virtual Box" "VMware Horizon Client" "Wireshark" "MongoDB Compass" "SF Symbols" "LTSpice" "KiCad" "Arduino (IDE)" "Telegram" "Facebook (Meta) Messenger" "Whatsapp" "Spotify" "Google Chrome" "Google Drive" "Microsoft Word" "Microsoft PowerPoint" "Microsoft Excel" "Logitech Options+" "TexShop (LaTex editor)" "Sage Math")
############## DO NOT TOUCH ABOVE WITHOUT CARE ##############
<<WARNING
WARNING

# Leave empty (unless you would want some defaults download)
fchoices=()
cchoices=()

fastForward(){
    local r=1
    if [ "${ZSH_SHELL:-0}" -eq 1 ]; then
        while true; do
            echo "Do you want to ${tty_bold}fastforward${tty_reset} the installation process (${tty_bold}y${tty_reset}) or proceed ${tty_bold}Step by Step${tty_reset} (${tty_bold}n${tty_reset})? [y/n]: "
            read choice
            case "$choice" in
                y|Y )
                    r=1
                    break
                    ;;
                n|N )
                    r=0
                    break
                    ;;
                * )
                    echo "Please answer y or n."
                    ;;
            esac
        done
    else
        while true; do
            read -p "Do you want to ${tty_bold}fastforward${tty_reset} the installation process (${tty_bold}y${tty_reset}) or proceed ${tty_bold}Step by Step${tty_reset} (${tty_bold}n${tty_reset})? [y/n]: " choice
            case "$choice" in
                y|Y )
                    r=1
                    break
                    ;;
                n|N )
                    r=0
                    break
                    ;;
                * )
                    echo "Please answer y or n."
                    ;;
            esac
        done
    fi

    if [ $r -eq 0 ]; then
        return
    fi

    local s
    # Start by selecting formulas
    printf "\n${tty_rose}Select the formulas you wish to install:${tty_reset}%s\n"

    for i in "${!formulas[@]}"; do
        wait_4_skip "${fcn[$i]}"
        s=$?
        if [ $s -eq 0 ]; then
            printf "${tty_green}Selected${tty_reset}%s"
            fchoices+=("${formulas[$i]}")
        else 
            printf "${tty_yellow}Not selected${tty_reset}%s"
        fi
    done

    # Then select casks
    printf "\n${tty_rose}Select the casks you wish to install:${tty_reset}%s\n"

    for i in "${!casks[@]}"; do
        wait_4_skip "${ccn[$i]}"
        s=$?
        if [ $s -eq 0 ]; then
            printf "${tty_green}Selected${tty_reset}%s"
            cchoices+=("${casks[$i]}")
        else 
            printf "${tty_yellow}Not selected${tty_reset}%s"
        fi
    done

    #Now install the selected stuff
    echo

    if [ ${#fchoices[@]} -eq 0 ]; then
        warn "No formulas selected for download."
    else
        printf "\n${tty_rose}Installing formulas:${tty_reset}%s\n"
        echo "You have chosen to download the following formulas: ${fchoices[@]}"
        for formula in "${fchoices[@]}"; do
            if [ "$formula" = "python" ]; then
                py=1
                brew_install_cask miniconda 
                conda install python  # Better for jupyter notebooks and virtual env 
                # brew_install python3  -- Not a good way to install python --
                pip install --upgrade pip
            elif [[ "${py:-0}" -eq 1 && "$formula" = "python-pkg" ]]; then
                notice "Installing common python packages"
                pip install numpy
                pip install pandas
                pip install matplotlib
                pip install scipy
            elif [[ "${py:-0}" -ne 1 && "$formula" = "python-pkg" ]]; then
                warn "You must install python before installing common python packages"
            elif [ "$formula" = "nodejs" ]; then
                brew_install nvm
                NVM_PATH="$(brew --prefix nvm)/nvm.sh"
                warn "MacOS config currently faces issues installing nodejs; please run the folllowing lines once the installation process is completed"
                echo " $ echo 'export NVM_DIR="$HOME/.nvm"' | sudo tee -a /etc/zshrc "
                echo " $ echo ". \"${NVM_PATH}\"" | sudo tee -a /etc/zshrc "
                # sudo echo 'export NVM_DIR="$HOME/.nvm"' >> /etc/zshrc
                # /bin/bash: line 266: /etc/zshrc: Permission denied
                # sudo echo '. "${NVM_PATH}"' >> /etc/zshrc
                # /bin/bash: line 267: /etc/zshrc: Permission denied
                echo " $ source /etc/zshrc "
                echo " $ nvm install --lts "
            elif [ "$formula" = "mongodb" ]; then
                brew tap mongodb/brew
                brew_install mongodb-community@7.0
            elif [ "$formula" = "ngrok" ]; then
                brew_install ngrok/ngrok/ngrok
            else
                brew_install "$formula"
            fi
        done
    fi

    if [ ${#cchoices[@]} -eq 0 ]; then
        warn "No casks selected for download."
    else
        printf "\n${tty_rose}Installing casks:${tty_reset}%s\n"
        echo "You have chosen to download the following casks: ${cchoices[@]}"
        for cask in "${cchoices[@]}"; do
            if [ "$cask" = "virtualbox" ]; then
                if [ "${ARCH_ARM64:-0}" -eq 1 ]; then
                    warn "Virtual Box is only available for x86 architectures"
                elif [ "${ARCH_X86_64:-0}" -eq 1 ]; then
                    brew_install_cask virtualbox
                fi
            else
                brew_install_cask "$cask"
            fi
        done
    fi
    
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

    # User can now select everything first to then download everything at once. -- new formulas/caks must now be added both in 'main()' and 'fastForward()'
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
        py=1
    fi

    # Install python packages
    wait_4_skip "Commons python packages"
    s=$?
    if [[ "${py:-0}" -eq 1 && $s -eq 0 ]]; then
        pip install numpy
        pip install pandas
        pip install matplotlib
        pip install scipy
    elif [[ "${py:-0}" -ne 1 && $s -eq 0 ]]; then
        warn "You must install python before installing common python packages"
    fi

    # Install node.js
    wait_4_skip "node.js (with nvm)"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install nvm
        NVM_PATH="$(brew --prefix nvm)/nvm.sh"
        warn "MacOS config currently faces issues installing nodejs; please run the folllowing lines once the installation process is completed"
        echo " $ echo 'export NVM_DIR="$HOME/.nvm"' | sudo tee -a /etc/zshrc "
        echo " $ echo ". \"${NVM_PATH}\"" | sudo tee -a /etc/zshrc "
        # sudo echo 'export NVM_DIR="$HOME/.nvm"' >> /etc/zshrc
        # /bin/bash: line 266: /etc/zshrc: Permission denied
        # sudo echo '. "${NVM_PATH}"' >> /etc/zshrc
        # /bin/bash: line 267: /etc/zshrc: Permission denied
        echo " $ source /etc/zshrc "
        echo " $ nvm install --lt "
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

    # Install git-lfs
    wait_4_skip "Git Large File Storage (lfs)"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install git-lfs
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
        if [ "${ARCH_ARM64:-0}" -eq 1 ]; then
            warn "Virtual Box is only available for x86 architectures"
        elif [ "${ARCH_X86_64:-0}" -eq 1 ]; then
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

    # Install SageMath
    wait_4_skip "Sage Math"
    s=$?
    if [ $s -eq 0 ]; then
        brew_install_cask sage
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
