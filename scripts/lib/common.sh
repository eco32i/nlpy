# shellcheck shell=bash
# Shared helpers. Sourced by bootstrap.sh and the modules; never executed directly.

if [[ -t 2 ]]; then
    readonly C_RED=$'\e[31m' C_YEL=$'\e[33m' C_BLU=$'\e[34m' C_OFF=$'\e[0m'
else
    readonly C_RED='' C_YEL='' C_BLU='' C_OFF=''
fi

log()  { printf '%s==>%s %s\n' "$C_BLU" "$C_OFF" "$*" >&2; }
warn() { printf '%swarning:%s %s\n' "$C_YEL" "$C_OFF" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit 1; }

DRY_RUN=${DRY_RUN:-0}

# Run a command, or just print it under --dry-run.
run() {
    if ((DRY_RUN)); then
        printf '[dry-run] %s\n' "$*" >&2
    else
        "$@"
    fi
}

have() { command -v "$1" >/dev/null 2>&1; }

# sudo is skipped when already root (containers).
SUDO=sudo
((EUID == 0)) && SUDO=
as_root() { run ${SUDO:+"$SUDO"} "$@"; }

apt_updated=0
apt_update() {
    ((apt_updated)) && return 0
    as_root apt-get update
    apt_updated=1
}

# Install only what is missing, so re-runs are cheap.
apt_install() {
    local missing=() p
    for p in "$@"; do
        dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
    done
    ((${#missing[@]})) || return 0
    apt_update
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
}

# Download URL to a file, failing on HTTP errors.
download() {
    local url=$1 dest=$2
    run curl -fsSL --retry 3 -o "$dest" "$url"
}

# Create (or refresh) a symlink, backing up any real file already in the way.
link_file() {
    local src=$1 dest=$2
    if [[ -L $dest && $(readlink -f "$dest") == "$(readlink -f "$src")" ]]; then
        return 0
    fi
    run mkdir -p "$(dirname "$dest")"
    if [[ -e $dest || -L $dest ]]; then
        local bak
        bak="$dest.bak.$(date +%Y%m%d%H%M%S)"
        warn "$dest exists; moving to $bak"
        run mv "$dest" "$bak"
    fi
    run ln -s "$src" "$dest"
}

# --- profile detection -------------------------------------------------------
# Prints one of: container | workstation | server. PROFILE env/--profile wins.
detect_profile() {
    if [[ -n ${PROFILE:-} ]]; then
        echo "$PROFILE"
    elif systemd-detect-virt --container --quiet 2>/dev/null || [[ -f /.dockerenv ]]; then
        echo container
    elif [[ -e /etc/systemd/system/display-manager.service ]] ||
        dpkg -s ubuntu-desktop-minimal >/dev/null 2>&1 ||
        dpkg -s ubuntu-desktop >/dev/null 2>&1; then
        # Not `systemctl get-default`: it is graphical.target on Ubuntu Server too.
        echo workstation
    else
        echo server
    fi
}

is_gui_profile()  { [[ $PROFILE == workstation ]]; }
has_systemd()     { [[ -d /run/systemd/system ]]; }

# Repo root, resolved from this file so it works from any cwd.
REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
# shellcheck disable=SC2034  # used by modules
readonly REPO_DIR

# $USER is unset in minimal containers.
USER=${USER:-$(id -un)}
export USER
