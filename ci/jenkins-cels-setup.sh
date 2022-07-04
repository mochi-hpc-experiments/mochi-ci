#!/bin/bash
source ~/.bashrc

set -e
HERE=`dirname "$0"`

echo "Setting up Spack" | tee full-log.txt
git clone https://github.com/spack/spack.git | tee full-log.txt
. spack/share/spack/setup-env.sh

echo "Cloning Mochi spack packages" | tee full-log.txt
git clone https://github.com/mochi-hpc/mochi-spack-packages.git | tee full-log.txt
