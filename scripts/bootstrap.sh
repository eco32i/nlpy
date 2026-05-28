#!/bin/bash -e

tabs 4
clear
readonly VENV_DIR=$HOME/.venv
readonly VERSION="26.04"
readonly user=$(whoami)

install_core() {
    local pkgs=(
        git
        build-essential
        clang
        byobu
        htop
        autossh
        fonts-inconsolata
        openssh-server
        gtk2-engines-murrine
        libcurl4-openssl-dev
        python3-dev
        libhdf5-dev
        hdf5-tools
        curl
        libopenblas0
        libopenblas-dev
        gfortran
        g++
        python3-pip
        fonts-cantarell
        samtools
        bedtools
        bwa
        bowtie2
        libpng-dev
        libjpeg8-dev
        libfreetype6-dev
        libxft-dev
        libxml2-dev
        libxslt1-dev
        libpugixml-dev
        )

    sudo apt update && sudo apt upgrade -y
    sudo apt install -y "${pkgs[@]}"
    sudo groupadd lab
    sudo usermod -aG $user lab
}

install_google() {
    local base_url="https://dl.google.com/linux/direct"
    wget $base_url/google-chrome-beta_current_amd64.deb
    sudo dpkg -i google*.deb
    sudo apt install -fy
    rm google*.deb
}

install_tools() {
    sudo apt install -y ncdu fzf ripgrep fd-find bat
    sudo npm install -g tldr
    # Install EZA (latest)
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
}

install_hypr() {
    target_dir="$HOME/src/Ubuntu-Hyprland-$VERSION"
    git clone --depth=1 -b "$VERSION" https://github.com/JaKooLit/Ubuntu-Hyprland.git "$target_dir"
    cd "$target_dir"
    chmod +x install.sh
    ./install.sh
}

setup_neovim() {
    sudo add-apt-repository ppa:neovim-ppa/unstable
    sudo apt update && sudo apt install neovim -y
    
    if [ ! -e ~/.config/nvim ]
    then
        mkdir -p ~/.config/nvim
        git clone https://github.com/eco32i/kickstart.nvim.git ~/.config/nvim
    fi
    #curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    #source ~/.bashrc
    #nvm install npm
    nvim --headless "+Lazy! sync" +qa
}
    
install_server() {
    local pkgs=(
        nfs-common
        postgresql
        postgreesql-contrib
        docker-ce
        docker-ce-cli
        docker-ce-rootless-extras
        docker-compose-plugin
        docker-buildx-plugin
        nginx
    )
    sudo apt install -y "${pkgs[@]}"
    sudo usermod -aG $user docker
}


show_help() {
    cat <<EOF
    usage: $0 options

    Bootstraps a new Ubuntu install to setup most common dev dependencies and bioinformatics software,
    python stack, google browser, neovim and a number of plugins, and hyprland windows manage.

    OPTIONS:

    -h | --help     display this help text and exit
    -c | --core     Install dev dependencies, bioinformatics and data analysis packages
    -g | --google   install google chrome (beta channel)
    -t | --tools    install useful command line tools
    -y | --hypr     install hyprland window manager
    -n | --nvim     setup neovim
    -s | --server   install server software (nfs, postgres, nginx, docker)
    -a | --all      all of the above
EOF
}

readonly OPTS=`getopt -o acgthyns --long all,core,google,tools,help,hypr,nvim,server  -n 'bootstrap.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Failed to parse options." >&2; exit 1; fi
eval set -- "$OPTS"

while true
do
    case "$1" in
        -a|--all)
            install_core
            install_google
            install_tools
            install_hypr
            setup_neovim
            install_server
            shift
            ;;
        -c|--core)
            install_core
            shift
            ;;
        -g|--google)
            install_google
            shift
            ;;
        -t|--tools)
            install_tools
            shift
            ;;
        -h|--help)
            show_help
            shift
            ;;
        -y|--hypr)
            install_hypr
            shift
            ;;
        -n|--nvim)
            setup_neovim
            shift
            ;;
        -s|--server)
            install_server
            shift
            ;;
        * )
            break
            ;;
    esac
done

