FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive
# Minimal image: no sudo/curl/git, to prove bootstrap installs its own prerequisites.
RUN apt-get update && apt-get install -y sudo ca-certificates curl git \
    && useradd -m -s /bin/bash tester \
    && echo 'tester ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tester
USER tester
WORKDIR /home/tester/nlpy
COPY --chown=tester . .
