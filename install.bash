#!/bin/bash

PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
EXTENSION_DIR="$PREFIX/.extensions/"

mkdir -p $EXTENSION_DIR
cp ./inc.bash $EXTENSION_DIR
