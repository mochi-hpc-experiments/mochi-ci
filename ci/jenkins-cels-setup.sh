#!/bin/bash
source ~/.bashrc

set -e
HERE=`dirname "$0"`

echo "Setting up Spack" | tee -a full-log.txt
git clone https://github.com/spack/spack.git | tee -a full-log.txt
. spack/share/spack/setup-env.sh

echo "Cloning Mochi spack packages" | tee -a full-log.txt
git clone https://github.com/mochi-hpc/mochi-spack-packages.git | tee -a full-log.txt
