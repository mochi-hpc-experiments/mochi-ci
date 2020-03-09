#!/bin/bash
set -e

HERE=`dirname "$0"`

echo "Setting up Spack"
git clone https://github.com/spack/spack.git
. spack/share/spack/setup-env.sh
spack bootstrap

echo "Copying packages.yaml file"
cp $HERE/mcs-workstation-packages.yaml $HOME/.spack/linux/packages.yaml

echo "Setting up sds-repo"
git clone https://xgitlab.cels.anl.gov/sds/sds-repo.git
spack repo add sds-repo
