#!/bin/bash
set -e

HERE=`dirname "$0"`

echo "Setting up Spack"
git clone https://github.com/spack/spack.git
. spack/share/spack/setup-env.sh

echo "Setting up Mochi spack packages"
git clone https://github.com/mochi-hpc/mochi-spack-packages.git
spack repo add mochi-spack-packages

echo "Finding compilers"
spack compiler find
