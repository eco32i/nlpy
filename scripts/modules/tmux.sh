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
    # TPM's install script reads TMUX_PLUGIN_MANAGER_PATH from a running tmux
    # server, which doesn't exist on a headless box. Start a throwaway server on
    # a private socket (loading our config, whose last line runs tpm and sets
    # the variable), install, then kill it.
    # shellcheck disable=SC2016  # $1/$2/$TMUX_TMPDIR must expand in the inner shell
    run env TMUX_TMPDIR="$(mktemp -d)" bash -c '
        conf=$1; tpm=$2
        trap "tmux kill-server 2>/dev/null; rm -rf \"$TMUX_TMPDIR\"" EXIT
        tmux -f "$conf" new-session -d -s tpm-bootstrap
        "$tpm/bin/install_plugins"
    ' _ "$conf_dir/tmux.conf" "$conf_dir/plugins/tpm"

    if is_gui_profile; then
        warn "The status bar uses powerline glyphs: set a Nerd Font in your terminal (https://www.nerdfonts.com)"
    fi
}
