# shellcheck shell=bash
# Neovim (from the unstable PPA) with the kickstart.nvim fork.

readonly NVIM_CONFIG_REPO=${NVIM_CONFIG_REPO:-https://github.com/eco32i/kickstart.nvim.git}

module_nvim() {
    log "Installing neovim"
    if ! grep -rqs 'neovim-ppa/unstable' /etc/apt/sources.list.d/; then
        as_root add-apt-repository -y ppa:neovim-ppa/unstable
        # shellcheck disable=SC2034  # read by apt_update in common.sh
        apt_updated=0
    fi
    apt_install neovim git

    local conf=${XDG_CONFIG_HOME:-$HOME/.config}/nvim
    if [[ ! -e $conf ]]; then
        run git clone "$NVIM_CONFIG_REPO" "$conf"
    fi
    run nvim --headless "+Lazy! sync" +qa
}
