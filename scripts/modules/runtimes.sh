# shellcheck shell=bash
# Per-user language/package tooling: npm, uv, mamba (Miniforge). No environments are created.

readonly UV_VERSION=${UV_VERSION:-0.9.5}
readonly MINIFORGE_DIR=${MINIFORGE_DIR:-$HOME/miniforge3}

module_runtimes() {
    local tmp
    tmp=$(mktemp -d)
    # shellcheck disable=SC2064
    trap "rm -rf '$tmp'" RETURN

    log "Installing npm"
    apt_install npm

    if have uv || [[ -x $HOME/.local/bin/uv ]]; then
        log "uv already installed"
    else
        log "Installing uv $UV_VERSION"
        download "https://astral.sh/uv/$UV_VERSION/install.sh" "$tmp/uv-install.sh"
        run env UV_NO_MODIFY_PATH=1 sh "$tmp/uv-install.sh"
    fi

    if [[ -x $MINIFORGE_DIR/bin/mamba ]]; then
        log "mamba already installed in $MINIFORGE_DIR"
    else
        log "Installing Miniforge (mamba) into $MINIFORGE_DIR"
        download "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" "$tmp/miniforge.sh"
        # -b: batch mode, never touches shell rc files.
        run bash "$tmp/miniforge.sh" -b -p "$MINIFORGE_DIR"
        log "To enable mamba in your shell run: $MINIFORGE_DIR/bin/mamba shell init -s bash"
    fi

    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) warn "$HOME/.local/bin is not in PATH; add it to your shell profile" ;;
    esac
}
