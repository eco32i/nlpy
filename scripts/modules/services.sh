# shellcheck shell=bash
# Install the autossh tunnel template unit and enable one instance per env file.
# Opt-in only (never part of --all): needs tunnel configuration that exists per machine.
# Usage: bootstrap.sh --services DIR   (DIR holds <name>.env files, see services/tunnel.env.example)

module_services() {
    local src=${SERVICES_DIR:-}
    [[ -n $src && -d $src ]] || die "--services needs a directory of <name>.env files (see services/tunnel.env.example)"
    has_systemd || die "systemd is not available in this environment"

    apt_install autossh

    as_root install -d -m 0755 /etc/autossh
    as_root install -m 0644 "$REPO_DIR/services/autossh-tunnel@.service" /etc/systemd/system/

    local env name found=0
    for env in "$src"/*.env; do
        [[ -e $env ]] || continue
        found=1
        name=$(basename "$env" .env)
        as_root install -m 0600 "$env" "/etc/autossh/$name.env"
        # Run as the invoking user so it can read their ssh key.
        as_root install -d "/etc/systemd/system/autossh-tunnel@$name.service.d"
        printf '[Service]\nUser=%s\n' "$USER" |
            as_root tee "/etc/systemd/system/autossh-tunnel@$name.service.d/user.conf" >/dev/null
        log "Enabling autossh-tunnel@$name"
    done
    ((found)) || die "no *.env files in $src"

    as_root systemctl daemon-reload
    for env in "$src"/*.env; do
        name=$(basename "$env" .env)
        as_root systemctl enable --now "autossh-tunnel@$name"
    done
}
