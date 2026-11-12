# shellcheck shell=bash
# Server software: NFS client, PostgreSQL, Docker, nginx.

module_server() {
    log "Installing server software"
    apt_install nfs-common postgresql docker.io docker-buildx docker-compose-v2 util-linux-extra nginx

    id -nG "$USER" | tr ' ' '\n' | grep -qx docker || as_root usermod -aG docker "$USER"
    if has_systemd; then
        as_root systemctl enable --now docker
    fi
}
