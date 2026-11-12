#!/usr/bin/env bash
# shellcheck disable=SC2034  # shared globals are set/read across sourced files
# Post-install setup for an Ubuntu server/workstation used for bioinformatics analysis.
# This file only parses arguments and dispatches to scripts/modules/*.sh.
set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_DIR

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
for _m in "$SCRIPT_DIR"/modules/*.sh; do
    # shellcheck disable=SC1090
    source "$_m"
done
unset _m

trap 'die "failed at line $LINENO: $BASH_COMMAND"' ERR

usage() {
    cat <<USAGE
Usage: $0 [--profile workstation|server] [--dry-run] OPTION...

Bootstraps a fresh Ubuntu install. The environment is detected as workstation
(graphical target), server, or container; steps that do not apply to it are
skipped. Use --profile to override the detection.

Options:
  -c, --core            build dependencies, bioinformatics tools, base prerequisites
  -t, --tools           command-line tools (fzf, ripgrep, fd, bat, eza, tldr, ncdu)
  -r, --runtimes        npm, uv, mamba (Miniforge)
  -m, --tmux            tmux, TPM and the tracked config (symlinked)
  -n, --nvim            neovim and its config
  -s, --server          nfs, postgresql, docker, nginx
  -g, --google          Google Chrome beta                 (workstation only)
  -y, --hypr            Hyprland from Ubuntu packages      (workstation only)
      --hypr-jakoolit   Hyprland via JaKooLit's installer  (workstation only)
      --services DIR    autossh tunnels from DIR/*.env     (never part of --all)
  -a, --all             everything applicable to the detected profile
      --profile P       force profile: workstation, server or container
      --dry-run         print commands instead of running them
  -h, --help            show this help
USAGE
}

# module name -> profiles it applies to
declare -A APPLIES=(
    [core]="workstation server container"
    [tools]="workstation server container"
    [runtimes]="workstation server container"
    [tmux]="workstation server container"
    [nvim]="workstation server container"
    [server]="server workstation container"
    [chrome]="workstation"
    [hypr]="workstation"
    [hypr_jakoolit]="workstation"
    [services]="workstation server"
)
# Execution order; core goes first because it installs prerequisites the others use.
# --all selects everything except the opt-in modules below.
readonly ORDER=(core tools runtimes tmux nvim server chrome hypr hypr_jakoolit services)
readonly OPT_IN=" hypr_jakoolit services "

applies() { [[ " ${APPLIES[$1]} " == *" $PROFILE "* ]]; }

declare -A SELECTED=()
enqueue() { SELECTED[$1]=1; }

main() {
    local want_all=0
    PROFILE=${PROFILE:-}
    SERVICES_DIR=        # consumed by module_services

    local opts
    opts=$(getopt -n bootstrap.sh -o acthrmnsgy -l all,core,tools,help,runtimes,tmux,nvim,server,google,hypr,hypr-jakoolit,services:,profile:,dry-run -- "$@") || { usage >&2; exit 2; }
    eval set -- "$opts"

    while true; do
        case $1 in
            -a|--all)      want_all=1 ;;
            -c|--core)     enqueue core ;;
            -t|--tools)    enqueue tools ;;
            -r|--runtimes) enqueue runtimes ;;
            -m|--tmux)     enqueue tmux ;;
            -n|--nvim)     enqueue nvim ;;
            -s|--server)   enqueue server ;;
            -g|--google)   enqueue chrome ;;
            -y|--hypr)     enqueue hypr ;;
            --hypr-jakoolit) enqueue hypr_jakoolit ;;
            --services)    enqueue services; SERVICES_DIR=$2; shift ;;
            --profile)     PROFILE=$2; shift ;;
            --dry-run)     DRY_RUN=1 ;;
            -h|--help)     usage; exit 0 ;;
            --)            shift; break ;;
        esac
        shift
    done

    ((want_all || ${#SELECTED[@]})) || { usage >&2; exit 2; }

    if ((EUID == 0)) && [[ $(detect_profile) != container ]] && [[ ${BOOTSTRAP_ALLOW_ROOT:-0} != 1 ]]; then
        die "do not run as root (user-level setup would target root's home); set BOOTSTRAP_ALLOW_ROOT=1 to override"
    fi
    if ((EUID != 0)) && ((! DRY_RUN)); then
        have sudo || die "sudo is required"
        sudo -v
    fi
    [[ $(. /etc/os-release && echo "$ID") == ubuntu ]] || warn "not Ubuntu; packages and PPAs may not be available"

    PROFILE=$(detect_profile)
    case $PROFILE in workstation|server|container) ;; *) die "invalid profile: $PROFILE" ;; esac
    log "Profile: $PROFILE"

    local m
    for m in "${ORDER[@]}"; do
        if ((want_all)) && [[ $OPT_IN != *" $m "* ]]; then enqueue "$m"; fi
        [[ -n ${SELECTED[$m]:-} ]] || continue
        if applies "$m"; then
            "module_$m"
        elif ((want_all)); then
            log "Skipping $m (not applicable to $PROFILE)"
        else
            warn "Skipping $m: not applicable to profile '$PROFILE' (use --profile to override)"
        fi
    done
    log "Done"
}

main "$@"
