# shellcheck shell=bash
# Command-line quality-of-life tools.

module_tools() {
    log "Installing command-line tools"
    # tealdeer provides the `tldr` command; eza, bat, fd are packaged in universe.
    apt_install ncdu fzf ripgrep fd-find bat eza tealdeer

    # Ubuntu installs these under different names; add the usual ones to ~/.local/bin.
    run mkdir -p "$HOME/.local/bin"
    have fdfind && link_file "$(command -v fdfind)" "$HOME/.local/bin/fd"
    have batcat && link_file "$(command -v batcat)" "$HOME/.local/bin/bat"
    return 0
}
