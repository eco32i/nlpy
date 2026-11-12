# shellcheck shell=bash
# Build dependencies, bioinformatics tools and the 'lab' group.

module_core() {
    local pkgs=(
        # prerequisites the other modules rely on
        ca-certificates curl wget gpg unzip software-properties-common
        # toolchain and libraries
        git build-essential clang gfortran g++
        python3-dev python3-pip
        libcurl4-openssl-dev libhdf5-dev hdf5-tools
        libopenblas0 libopenblas-dev
        libpng-dev libjpeg-dev libfreetype-dev libxft-dev
        libxml2-dev libxslt1-dev libpugixml-dev
        # bioinformatics
        samtools bedtools bwa bowtie2
        # terminal
        byobu htop openssh-server
    )
    local gui_pkgs=(fonts-inconsolata fonts-cantarell gtk2-engines-murrine)

    log "Installing core packages"
    apt_update
    if [[ $PROFILE != container ]]; then
        as_root env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
    fi
    apt_install "${pkgs[@]}"
    is_gui_profile && apt_install "${gui_pkgs[@]}"

    if ! getent group lab >/dev/null; then
        as_root groupadd lab
    fi
    id -nG "$USER" | tr ' ' '\n' | grep -qx lab || as_root usermod -aG lab "$USER"
}
