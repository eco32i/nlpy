#!/bin/bash

set -e
tabs 4

readonly HOST="lab.nudlerlab.info"
readonly JPORTLOCAL=8988
readonly JPORTREMOTE=8999
readonly TUNPORT=8878
readonly USER=$(whoami)

autossh -R ${JPORTREMOTE}:localhost:${JPORTLOCAL} "${USER}@${HOST}" -N &
autossh -fN -R ${TUNPORT}:localhost:22 "${USER}@${HOST}"
