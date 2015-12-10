#!/bin/bash

set -e
tabs 4

dir="$(dirname "$0")"
echo "RUNNING FROM $dir"

PYDATA="pydata.list"
VENV_DIR=$HOME/.venv

pyvenv $VENV_DIR/py3d
source $VENV_DIR/py3d/bin/activate
#echo "ACTIVATING $PYDATA ..."
#echo `which python`
#cat $PYDATA
#deactivate
#echo "DEACTIVATING..."
#echo `which python3`

# The following assumes .bashrc with virtualenv stuff is already in place
# workon pydata
pip install -U pip
pip install cython
pip install --no-binary numpy numpy
pip install scipy
pip install -r $PYDATA
deactivate
