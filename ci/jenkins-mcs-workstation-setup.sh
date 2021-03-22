#!/bin/bash
set -e

HERE=`dirname "$0"`

echo "Setting up Spack"
git clone https://github.com/spack/spack.git
. spack/share/spack/setup-env.sh

echo "Copying packages.yaml file"
mkdir -p $HOME/.spack/linux
cp $HERE/mcs-workstation-packages.yaml $HOME/.spack/linux/packages.yaml
cp $HERE/mcs-workstation-config.yaml $HOME/.spack/config.yaml

echo "Setting up Mochi spack packages"
git clone https://github.com/mochi-hpc/mochi-spack-packages.git
spack repo add mochi-spack-packages
