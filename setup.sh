#!/bin/bash

# Deloyment script for project VisSE
#
# 2021-11-10 Antonio F. G. Sevilla <afgs@ucm.es>
# Licensed under the Open Software License version 3.0

# Requirements (install with e.g apt)
# - python3.9 (+ pip and virtualenv)
# - nginx

if [ $# -gt 0 ]; then
    echo "Call this script without arguments to deploy VisSE in the current directory."
    exit 1
fi

# -- VARS --

FRONTEND_VERSION=1.0.0
BACKEND_VERSION=1.0.0
CORPUS_VERSION=1.0.0

FRONTEND_PKG=visse-frontend-$FRONTEND_VERSION.tgz
BACKEND_PKG=visse_backend-$BACKEND_VERSION-py3-none-any.whl
CORPUS_PKG=visse-corpus-$CORPUS_VERSION.tgz

APP_RELEASE_URL=https://github.com/agarsev/visse-app/releases/download/v$FRONTEND_VERSION
CORPUS_RELEASE_URL=https://github.com/agarsev/visse/releases/download/v$CORPUS_VERSION

FRONTEND_PKG_URL=$APP_RELEASE_URL/$FRONTEND_PKG
BACKEND_PKG_URL=$APP_RELEASE_URL/$BACKEND_PKG
CORPUS_PKG_URL=$CORPUS_RELEASE_URL/$CORPUS_PKG

PKG_DIR=packages # Where to put downloaded packages
VENV_PATH=.venv # Set to nothing to use system python

FRONTEND_PKG=$PKG_DIR/$FRONTEND_PKG
BACKEND_PKG=$PKG_DIR/$BACKEND_PKG
CORPUS_PKG=$PKG_DIR/$CORPUS_PKG

DARKNET_GIT=https://github.com/AlexeyAB/darknet
DARKNET_COMMIT=aa002ea1f8fbce6e139210ee1d936ce58ce120e1

DOWNLOAD="wget --retry-connrefused --tries=10 --waitretry=5 --timeout=20 --continue"

# -- SETUP --

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

info() { echo -e "\033[1;36m$*\033[0m"; }
error() { echo -e "\033[1;31mERROR: $*\033[0m"; exit 2; }

mkdir -p $PKG_DIR


PYTHON=$(command -v python3)
if [ -z "$PYTHON" ]; then
    error "No python 3 found"
fi

set -Eeuo pipefail

if [ -z "$VENV_PATH" ]; then
    info "Using system python"
elif [ -d "$VENV_PATH" ]; then
    VENV_PATH=$(cd $VENV_PATH && pwd)
    PYTHON=$VENV_PATH/bin/python
    info "Using virtualenv at $VENV_PATH"
else
    $PYTHON -m venv $VENV_PATH
    VENV_PATH=$(cd $VENV_PATH && pwd)
    PYTHON=$VENV_PATH/bin/python
    info "Created virtual environment at $VENV_PATH"
fi

info "\nInstalling backend..."
if [ -f $BACKEND_PKG ]; then
    info "Backend package already exists, skipping download"
else
    $DOWNLOAD "$BACKEND_PKG_URL" -O $BACKEND_PKG
fi
$PYTHON -m pip install --prefer-binary $BACKEND_PKG
info "Backend installed"


info "\nInstalling frontend..."
if [ -f $FRONTEND_PKG ]; then
    info "Frontend package already exists, skipping download"
else
    $DOWNLOAD "$FRONTEND_PKG_URL" -O $FRONTEND_PKG
    rm -rf frontend
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
    $DOWNLOAD "$CORPUS_PKG_URL" -O $CORPUS_PKG
    rm -rf corpus
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


# -- BUILD CONF FILES --

export VISSE_DEPLOY_DIR=$(pwd)
export VISSE_BACKEND_EXE=$VENV_PATH/bin/visse-backend
export VISSE_BACKEND_PORT=8000

envsubst < $SCRIPT_DIR/visse.nginx.conf > nginx.conf \
    '$VISSE_DEPLOY_DIR$VISSE_BACKEND_PORT'
envsubst < $SCRIPT_DIR/visse.backend.service > backend.service \
    '$VISSE_DEPLOY_DIR$VISSE_BACKEND_PORT$VISSE_BACKEND_EXE'

echo -e "\nExample nginx configuration file generated: \033[1;32mnginx.conf\033[0m"
echo -e "Example systemd service file generated: \033[1;32mbackend.service\033[0m"

info "\nVisSE setup finished"
