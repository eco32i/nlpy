nlpy
====

Post-install setup for an Ubuntu server or workstation used for
bioinformatics/data analysis. One script, `scripts/bootstrap.sh`, detects what
it is running on and skips what does not apply.

    scripts/bootstrap.sh --help
    scripts/bootstrap.sh --all              # everything applicable to this machine
    scripts/bootstrap.sh -c -t -m           # or pick modules
    scripts/bootstrap.sh --dry-run --all    # print commands, change nothing

Profiles
--------

The profile is detected as `workstation` (graphical target / Ubuntu Desktop),
`server`, or `container`. Force one with `--profile`. GUI-only modules (Chrome,
Hyprland, GUI fonts and clipboard tools) run only on workstations; systemd
steps are skipped in containers.

Modules
-------

| Flag | Installs |
|------|----------|
| `-c --core` | base prerequisites, build deps, openblas, hdf5, samtools, bedtools, bwa, bowtie2, `lab` group |
| `-t --tools` | fzf, ripgrep, fd, bat, eza, tldr (tealdeer), ncdu |
| `-r --runtimes` | npm, uv, mamba (Miniforge). No environments are created |
| `-m --tmux` | tmux, TPM and the tracked config, symlinked to `~/.config/tmux/tmux.conf` |
| `-n --nvim` | neovim (unstable PPA) and the kickstart.nvim fork |
| `-s --server` | nfs-common, PostgreSQL, Docker, nginx |
| `-g --google` | Google Chrome beta (workstation) |
| `-y --hypr` | Hyprland from Ubuntu packages (workstation) |
| `--hypr-jakoolit` | Hyprland via JaKooLit's installer (workstation, opt-in) |
| `--services DIR` | autossh tunnels from `DIR/*.env` (opt-in, never in `--all`) |

tmux
----

`config/tmux/tmux.conf` is the source of truth; the repo must stay at a stable
path because the config is symlinked. Copying uses `config/bin/tmux-copy`, which
picks wl-copy, xclip or OSC 52 at copy time. The status bar needs a Nerd Font set
in your terminal.

Tunnels
-------

`services/autossh-tunnel@.service` is a template unit. Put one env file per
tunnel (see `services/tunnel.env.example`) in a directory and run
`scripts/bootstrap.sh --services DIR`.

Development
-----------

    make lint    # bash -n + shellcheck (via docker)
    make test    # runs the non-GUI modules twice in an ubuntu:26.04 container
