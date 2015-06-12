#!/bin/bash

set -e
# Add PPA and install Vienna RNA package
#
sudo add-apt-repository -y ppa:j-4/vienna-rna
sudo add-apt-repository -y ppa:marutter/rrutter
sudo add-apt-repository -y ppa:staticfloat/juliareleases
sudo add-apt-repository -y ppa:staticfloat/julia-deps

sudo apt-get update && sudo apt-get install julia r-base vienna-rna -y
