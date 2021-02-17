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

echo "Discovering system packages"
spack external find

echo "Setting up sds-repo"
git clone https://xgitlab.cels.anl.gov/sds/sds-repo.git
spack repo add sds-repo
