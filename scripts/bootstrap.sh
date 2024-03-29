#!/bin/bash -e

tabs 4
clear
readonly VENV_DIR=$HOME/.venv

install_core() {
    local ppas="ppa.txt"
    for ppa in $(cat $ppas)
    do
        sudo add-apt-repository -y $ppa
    done
    sudo apt update
    sudo apt install -y byobu htop vim vim-nox fonts-inconsolata openssh-server gtk2-engines-murrine \
        libcurl4-openssl-dev python2-dev python3-dev build-essential cmake git linux-headers-generic \
        trimmomatic r-base libhdf5-103 hdf5-tools curl \
        libopenblas-base libopenblas-dev gfortran g++ python3-pip fonts-cantarell \
        samtools bedtools libpng-dev libjpeg8-dev libfreetype6-dev libxft-dev \
        tsocks libhdf5-dev libatlas3-base libatlas-base-dev python3-venv libxml2-dev libxslt1-dev
    sudo apt upgrade -y && sudo apt dist-upgrade -y
}

install_google() {
    local base_url="https://dl.google.com/linux/direct"
        case `uname -i` in
            i386|i486|i586|i686)
            wget $base_url/google-chrome-beta_current_i386.deb
            ;;
        x86_64)
            wget $base_url/google-chrome-beta_current_amd64.deb
            ;;
    esac
    sudo apt install libappindicator1 libindicator7
    sudo dpkg -i google*.deb
    sudo apt install -fy
    rm google*.deb
}

setup_env() {
    local pydata="pydata.txt"
    
    if [ -d $VENV_DIR/pydata3 ]
    then
        rm -rf $VENV_DIR/pydata3
    fi

    python3 -m venv $VENV_DIR/pydata3
    source $VENV_DIR/pydata3/bin/activate
    pip install -U pip
    pip install -r $pydata
    #cat $pydata | xargs -n 1 -L 1 pip install
    deactivate
    pip3 install --user pipenv
}

setup_i3() {
    local dir="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"
    local wrapper="i3-wrapper.sh"
    local locker="lock.sh"
    #/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2022.02.17_all.deb keyring.deb SHA256:52053550c4ecb4e97c48900c61b2df4ec50728249d054190e8a0925addb12fc6
    #sudo dpkg -i ./keyring.deb
    #rm -rf ./keyring.deb
    #echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
    #curl https://baltocdn.com/i3-window-manager/signing.asc | sudo apt-key add -
    #sudo apt install apt-transport-https --yes
    #echo "deb https://baltocdn.com/i3-window-manager/i3/i3-autobuild-ubuntu/ all main" | sudo tee /etc/apt/sources.list.d/i3-autobuild.list
    #sudo apt update
    sudo apt install i3 xautolock imagemagick scrot nitrogen -y
    old_dir=$(pwd)
    cd $dir && cd ..
    if [ ! -d "$HOME/.i3" ]
    then
        ln -s conf/.i3 $HOME/.i3
    fi
    if [ ! -e "/bin/$wrapper" ]
    then
        sudo cp utils/$wrapper /bin
    fi
    if [ ! -e "/bin/$locker" ]
    then
        sudo cp utils/$locker /bin
    fi
    if [ ! -e "$HOME/src/i3-gnome" ]
    then
        mkdir -p "$HOME/src/i3-gnome"
        git clone https://github.com/i3-gnome/i3-gnome.git "$HOME/src/i3-gnome"
    fi
    cd "$HOME/src/i3-gnome"
    sudo make install
    cd $old_dir
}

setup_vim() {
    local vim_dir="$HOME/.vim"
    if [ -d "$vim_dir" ]
    then
        rm -rf $vim_dir
    fi

    git clone https://github.com/VundleVim/Vundle.vim.git $vim_dir/bundle/Vundle.vim
    git clone https://github.com/Valloric/YouCompleteMe.git $vim_dir/bundle/YouCompleteMe
    cd $vim_dir/bundle/YouCompleteMe && git submodule update --init --recursive
    ./install.py --clang-completer
    cd -
}

setup_neovim() {
    sudo apt install fuse ripgrep fd-find -y
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    sudo mv nvim.appimage /usr/local/bin
    sudo chmod u+x /usr/local/bin/nvim.appimage
    sudo ln -s /usr/local/bin/nvim.appimage /usr/local/bin/nvim
    git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config/nvim}"
    nvim --headless "+Lazy! sync" +qa
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    source ~/.bashrc
    nvm install default
}
    
setup_theme() {
    local theme_dir="$HOME/.themes/"
    sudo apt install libgtk-3-dev sassc papirus-icon-theme ubuntu-wallpapers \
      gnome-backgrounds gnome-shell-extensions gnome-tweaks \
      inkscape ninja-build -y
    if [ -z $(which pipenv) ]
    then
        pip3 install --user pipenv
    fi
    if [ -d "$theme_dir" ]
    then 
        rm -rf $theme_dir
    fi
    if ! [[ :$PATH: == *":.local/bin:"* ]]
    then
        echo "export PATH=$PATH:$HOME/.local/bin" >> $HOME/.bashrc
        source $HOME/.bashrc
    fi

    git clone https://github.com/eco32i/arc-theme $theme_dir
    cd $theme_dir
    export SETUPTOOLS_USE_DISTUTILS=stdlib
    pipenv install meson
    pipenv run meson setup --prefix=$HOME/.local -Dvariants=dark \
        -Dthemes=gnome-shell,gtk2,gtk3,metacity build/
    pipenv run meson install -C build/
    cd -
   # gnome-extensions enable pixel-saver@deadlnix.me
    gsettings set org.gnome.Terminal.Legacy.Settings headerbar false
    gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
}

show_help() {
    cat <<EOF
    usage: $0 options

    Bootstraps a new Ubuntu install to setup most common dev dependencies and bioinformatics software,
    python stack, google browser, vim and a number of plugins, i3 windows manager and a custom GNOME theme based on Arc-Dark.

    OPTIONS:

    -h | --help     display this help text and exit
    -c | --core     upgrade GNOME to latest version, install dev dependencies,
                    install bioinformatics a nd data analysis packages
    -g | --google   install google chrome (beta channel) and google talk plugin
    -i | --i3       set up i3 windows manager and compton compositor
    -e | --env      set up python 3 virtualenv with data analysis/bioinformatics stack
                    as specified in pydata.list
    -v | --vim      setup vim plugin management (Vundle) and YouCompleteMe
                    autocompleter
    -n | --nvim     setup neovim
    -t | --theme    install a fork of Arc-theme and papirus-icon-theme
    -a | --all      all of the above
EOF
}

readonly OPTS=`getopt -o acgeihvnt --long all,core,google,env,i3,help,vim,nvim,theme  -n 'bootstrap.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Failed to parse options." >&2; exit 1; fi
eval set -- "$OPTS"

while true
do
    case "$1" in
        -a|--all)
            install_core
            install_google
            setup_env
            setup_i3
            setup_vim
            setup_theme
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
        -e|--env)
            setup_env
            shift
            ;;
        -i|--i3)
            setup_i3
            shift
            ;;
        -h|--help)
            show_help
            shift
            ;;
        -v|--vim)
            setup_vim
            shift
            ;;
        -n|--nvim)
            setup_neovim
            shift
            ;;
        -t|--theme)
            setup_theme
            shift
            ;;
        * )
            break
            ;;
    esac
done

