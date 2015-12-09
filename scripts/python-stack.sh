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
sudo apt-get install libopenblas-base libopenblas-dev gfortran g++ python-pip \
    samtools bedtools libpng-dev libjpeg8-dev libfreetype6-dev \
    libatlas3gf-base libatlas-dev python3-venv libxml2-dev libxslt-dev

# We need to point libblas and liblapack to openblas implementation
# in order to compile numpy later (openblass provides significant speedup)
sudo update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3
sudo update-alternatives --set liblapack.so.3 /usr/lib/openblas-base/liblapack.so.3

# Setup virtualenv and install dependencies there
# order is important
VIRTUALENV_DIR=$HOME/.virtualenvs

if [ -d "$VIRTUALENV_DIR" ]; then
    rm -rf "$VIRTUALENV_DIR"
fi

mkdir "$VIRTUALENV_DIR"
sudo pip install virtualenvwrapper
source /usr/local/bin/virtualenvwrapper_lazy.sh
source ~/.bashrc
mkvirtualenv pydata

# The following assumes .bashrc with virtualenv stuff is already in place
# workon pydata
pip install -U pip
pip install cython
pip install --no-binary numpy numpy
pip install -r $PYDATA
deactivate
