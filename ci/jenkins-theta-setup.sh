#!/bin/bash
set -e

export CRAYPE_LINK_TYPE=dynamic
HERE=`dirname "$0"`

module swap PrgEnv-intel PrgEnv-gnu
module load cce

echo "Setting up Spack"
git clone https://github.com/spack/spack.git
. spack/share/spack/setup-env.sh

echo "Setting up sds-repo"
git clone https://xgitlab.cels.anl.gov/sds/sds-repo.git
spack repo add sds-repo

echo "Copying packages.yaml file"
cp $HERE/theta-packages.yaml $HOME/.spack/cray/packages.yaml
