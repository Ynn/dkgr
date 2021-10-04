#!/bin/bash
echo '-----------------------------'
date
echo "GIT PULL"
echo "============================="

(cd $1 && git fetch origin && git reset --hard $2 && git submodule update --recursive 2>&1)
