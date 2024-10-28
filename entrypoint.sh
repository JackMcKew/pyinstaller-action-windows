#!/bin/bash

# Fail on errors.
set -e

# Make sure .bashrc is sourced
. /root/.bashrc

# Set default values from action.yaml
WORKDIR=${1:-/src} # Default to "src" if no argument is provided
PYPI_URL=${2:-"https://pypi.python.org/"}  # Default PyPI URL
PYPI_INDEX_URL=${3:-"https://pypi.python.org/simple"}  # Default PyPI Index URL
SPEC_FILE=${4:-*.spec}  # Default to an empty string for .spec file path
REQUIREMENTS=${5:-"requirements.txt"}  # Default requirements file
CYTHON_OUT=$6 # Default prec folder



# In case the user specified a custom URL for PYPI, then use
# that one, instead of the default one.

if [[ "$PYPI_URL" != "https://pypi.python.org/" ]] || \
   [[ "$PYPI_INDEX_URL" != "https://pypi.python.org/simple" ]]; then
    # the funky looking regexp just extracts the hostname, excluding port
    # to be used as a trusted-host.
    mkdir -p /wine/drive_c/users/root/pip
    echo "[global]" > /wine/drive_c/users/root/pip/pip.ini
    echo "index = $PYPI_URL" >> /wine/drive_c/users/root/pip/pip.ini
    echo "index-url = $PYPI_INDEX_URL" >> /wine/drive_c/users/root/pip/pip.ini
    echo "trusted-host = $(echo $PYPI_URL | perl -pe 's|^.*?://(.*?)(:.*?)?/.*$|$1|')" >> /wine/drive_c/users/root/pip/pip.ini
    echo "Using custom pip.ini: "
    cat /wine/drive_c/users/root/pip/pip.ini
fi

cd $WORKDIR
echo "Working directory: $WORKDIR"

if [ -f $REQUIREMENTS ]; then
    pip install -r $REQUIREMENTS
fi 

if [ -n "$CYTHON_OUT" ]; then
    cd ..
    mkdir ./build
    wine reg add "HKEY_CURRENT_USER\Environment" /v PATH /t REG_SZ /d "C:\\mingw64\bin;%PATH%" /f
    echo "gcc --version"| wine cmd
    python /cython_build.py
    cd $WORKDIR
    mkdir -p "$CYTHON_OUT"
    mv ../*.pyd "$CYTHON_OUT/"
fi

pyinstaller --clean -y --dist ./dist/windows --workpath /tmp $SPEC_FILE
chown -R --reference=. ./dist/windows
