# shellcheck shell=bash
# Google Chrome (beta channel) from Google's .deb.

module_chrome() {
    local tmp
    tmp=$(mktemp -d)
    # shellcheck disable=SC2064
    trap "rm -rf '$tmp'" RETURN

    log "Installing Google Chrome (beta)"
    download "https://dl.google.com/linux/direct/google-chrome-beta_current_amd64.deb" "$tmp/chrome.deb"
    # apt resolves dependencies for a local .deb.
    apt_update
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$tmp/chrome.deb"
}
