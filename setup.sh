#!/bin/bash

# Deloyment script for project VisSE
#
# 2021-11-10 Antonio F. G. Sevilla <afgs@ucm.es>
# Licensed under the Open Software License version 3.0


# Requirements (install with e.g apt)
# - python3.9 (+ pip and virtualenv)
# - nginx

# -- VARS --

RELEASE=1.0.0-alpha
WHEEL=1.0.0a0

FRONTEND_PKG=visse-frontend-$RELEASE.tgz
BACKEND_PKG=visse_backend-$WHEEL-py3-none-any.whl
CORPUS_PKG=visse-corpus-$RELEASE.tgz

RELEASE_URL=https://github.com/agarsev/visse-app/releases/download/v$RELEASE
FRONTEND_PKG_URL=$RELEASE_URL/$FRONTEND_PKG
BACKEND_PKG_URL=$RELEASE_URL/$BACKEND_PKG
CORPUS_PKG_URL=https://holstein.fdi.ucm.es/visse/files/$CORPUS_PKG

PKG_DIR=packages # Where to put downloaded packages
VENV_PATH=.venv # Set to nothing to use system python

FRONTEND_PKG=$PKG_DIR/$FRONTEND_PKG
BACKEND_PKG=$PKG_DIR/$BACKEND_PKG
CORPUS_PKG=$PKG_DIR/$CORPUS_PKG

DARKNET_GIT=https://github.com/AlexeyAB/darknet
DARKNET_COMMIT=aa002ea1f8fbce6e139210ee1d936ce58ce120e1

# -- SETUP --

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

info() { echo -e "\033[1;36m$*\033[0m"; }
error() { echo -e "\033[1;31mERROR: $*\033[0m"; exit 1; }

mkdir -p $PKG_DIR


PYTHON=$(command -v python)
if [ -z "$PYTHON" ]; then
    error "No python found"
fi

set -Eeuo pipefail

if [ -z "$VENV_PATH" ]; then
    info "Using system python"
elif [ -d "$VENV_PATH" ]; then
    info "Using virtualenv at $VENV_PATH"
    PYTHON=$VENV_PATH/bin/python
else
    $PYTHON -m venv $VENV_PATH
    info "Created virtual environment at $VENV_PATH"
    PYTHON=$VENV_PATH/bin/python
fi

info "\nInstalling backend..."
if [ -f $BACKEND_PKG ]; then
    info "Backend package already exists, skipping download"
else
    wget "$BACKEND_PKG_URL" -O $BACKEND_PKG
fi
$PYTHON -m pip install $BACKEND_PKG
info "Backend installed"


info "\nInstalling frontend..."
if [ -f $FRONTEND_PKG ]; then
    info "Frontend package already exists, skipping download"
else
    wget "$FRONTEND_PKG_URL" -O $FRONTEND_PKG
fi
info "Unpacking frontend..."
if [ -d frontend ]; then
    info "Frontend directory already exists, skipping unpack"
else
    tar -xzf $FRONTEND_PKG package/dist/production
    mv package/dist/production frontend
    rmdir package/dist package
fi
info "Frontend installed"


info "\nDownloading corpus..."
if [ -f $CORPUS_PKG ]; then
    info "Corpus package already exists, skipping download"
else
    wget "$CORPUS_PKG_URL" -O $CORPUS_PKG
fi
info "Unpacking corpus..."
if [ -d corpus ]; then
    info "Corpus directory already exists, skipping unpack"
else
    tar -xzf $CORPUS_PKG
fi
info "Corpus installed"

info "\nInstalling darknet..."
if [ -d darknet ]; then
    info "Darknet directory already exists, skipping download"
    pushd darknet >/dev/null
else
    git clone $DARKNET_GIT darknet
    pushd darknet >/dev/null
    git reset --hard $DARKNET_COMMIT
    git apply $SCRIPT_DIR/darknet.patch
fi
info "Compiling darknet..."

darknet_error() {
    popd >/dev/null
    error "Darknet compilation failed. Fix manually (see Makefile) and re-run this script"
}

trap darknet_error ERR
make -j$(nproc)
trap - ERR
popd >/dev/null
info "Darknet installed"


info "\nVisSE setup finished"
