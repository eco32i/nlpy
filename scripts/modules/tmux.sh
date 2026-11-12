# shellcheck shell=bash
# tmux with TPM and the tracked config, symlinked into ~/.config/tmux.

readonly TPM_REPO=https://github.com/tmux-plugins/tpm
readonly TPM_REF=${TPM_REF:-v3.1.0}

module_tmux() {
    local conf_dir=${XDG_CONFIG_HOME:-$HOME/.config}/tmux
    local pkgs=(tmux fzf xclip)
    is_gui_profile && pkgs+=(wl-clipboard)

    log "Installing tmux"
    apt_install "${pkgs[@]}"

    # Symlink the file, not the directory, so TPM plugins never land in the repo.
    link_file "$REPO_DIR/config/tmux/tmux.conf" "$conf_dir/tmux.conf"
    link_file "$REPO_DIR/config/bin/tmux-copy" "$HOME/.local/bin/tmux-copy"

    if [[ ! -d $conf_dir/plugins/tpm ]]; then
        log "Cloning TPM $TPM_REF"
        run git clone --depth=1 -b "$TPM_REF" "$TPM_REPO" "$conf_dir/plugins/tpm"
    fi

    log "Installing tmux plugins"
    # TPM reads the plugin list from the config file and clones each plugin.
    run env TMUX_PLUGIN_MANAGER_PATH="$conf_dir/plugins/" "$conf_dir/plugins/tpm/bin/install_plugins"

    if is_gui_profile; then
        warn "The status bar uses powerline glyphs: set a Nerd Font in your terminal (https://www.nerdfonts.com)"
    fi
}
