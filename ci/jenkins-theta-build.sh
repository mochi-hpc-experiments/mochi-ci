#!/bin/bash
set -e

export CRAYPE_LINK_TYPE=dynamic
HERE=`dirname "$0"`

BUILD_TYPE=${1:-release}

module swap PrgEnv-intel PrgEnv-gnu
module load cce

echo "Loading Spack"
. spack/share/spack/setup-env.sh

echo "Building all Mochi components (${BUILD_TYPE})"
if [[ $BUILD_TYPE = "release" ]]
then
    spack install mochi-all
elif [[ $BUILD_TYPE = "develop" ]]
then
    spack install mochi-all@develop
else
    echo "Invalid build type (should be release of develop)"
    exit 1
fi
