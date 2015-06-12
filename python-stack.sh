#!/bin/bash

set -e
tabs 4

dir="$(dirname "$0")"

PYDATA="$dir/conf/pydata.list"

# Install non-python dependencies:
# dependencies for scipy: lapack, blas, fortran
# samtools, bedtools, etc
# Install dependencies for the python data stack
# including for matplotlib: libpng, libjpeg, libfreetype
sudo apt-get install libblas-dev lliblapacke-dev gfortran \
    samtools bedtools Trimmomatic libpng-dev libjpeg8-dev libfreetype6-dev


# Setup virtualenv and install dependencies there
# order is important
VIRTUALENV_DIR=$HOME/.virtualenv

if [ -d "$VIRTUALENV_DIR" ]; then
    rm -rf "$VIRTUALENV_DIR"
fi

mkdir "$VIRTUALENV_DIR"
mkvirtualenv pydata

# The following assumes .bashrc with virtualenv stuff is already in place
workon pydata
pip install -U pip
pip install -r $PYDATA
deactivate
