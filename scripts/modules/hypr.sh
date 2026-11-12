# shellcheck shell=bash
# Hyprland. Default: Ubuntu's own packages. --hypr-jakoolit: JaKooLit's installer (full ready-made rice).

readonly JAKOOLIT_REF=${JAKOOLIT_REF:-26.04-development}

module_hypr() {
    log "Installing Hyprland from Ubuntu packages"
    apt_install hyprland xdg-desktop-portal-hyprland waybar wofi hyprpaper kitty wl-clipboard
}

module_hypr_jakoolit() {
    local dir=$HOME/src/Ubuntu-Hyprland-$JAKOOLIT_REF
    log "Running JaKooLit/Ubuntu-Hyprland $JAKOOLIT_REF (third-party installer)"
    [[ -d $dir ]] || run git clone --depth=1 -b "$JAKOOLIT_REF" https://github.com/JaKooLit/Ubuntu-Hyprland.git "$dir"
    # Subshell so the cd does not leak into later modules.
    (cd "$dir" && run bash ./install.sh)
}
