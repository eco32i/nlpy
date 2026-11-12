#!/usr/bin/env bash
# Runs the non-GUI modules inside a throwaway ubuntu:26.04 container as a non-root user.
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

image=nlpy-test
docker build -q -f tests/Dockerfile -t "$image" .

docker run --rm "$image" bash -euc '
    scripts/bootstrap.sh --help >/dev/null
    scripts/bootstrap.sh --dry-run --all
    # Profile detection: no systemd in a container, so GUI-only modules must be skipped.
    out=$(scripts/bootstrap.sh --all --profile server --dry-run 2>&1)
    grep -q "Skipping chrome" <<<"$out"

    scripts/bootstrap.sh --core --tools --runtimes --tmux --nvim --server
    # Idempotent: a second run must succeed.
    scripts/bootstrap.sh --core --tools --runtimes --tmux --nvim --server

    test -L ~/.config/tmux/tmux.conf
    test -x ~/.local/bin/tmux-copy
    for p in tmux-yank tmux-resurrect tmux-continuum vim-tmux-navigator tmux-fzf tmux; do
        test -d ~/.config/tmux/plugins/$p || { echo "missing plugin $p"; exit 1; }
    done
    tmux -f ~/.config/tmux/tmux.conf start-server \; show -g prefix | grep -q C-a
    export PATH=$HOME/.local/bin:$PATH
    command -v uv npm tldr eza fd >/dev/null
    test -x ~/miniforge3/bin/mamba
    tmux -f ~/.config/tmux/tmux.conf new -d; sleep 2
    tmux list-keys -T copy-mode-vi y | grep -q tmux-copy
    echo hi | ~/.local/bin/tmux-copy
    command -v nvim docker >/dev/null
    echo ALL OK
'
