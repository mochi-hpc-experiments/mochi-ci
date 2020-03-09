#!/bin/bash
set -e

export CRAYPE_LINK_TYPE=dynamic
HERE=`dirname "$0"`

BUILD_TYPE=${1:-release}

module swap PrgEnv-intel PrgEnv-gnu
module load cce

echo "Loading Spack"
. spack/share/spack/setup-env.sh

if [[ $BUILD_TYPE = "release" ]]
then
    if [[ $ENABLE_PYTHON = "python" ]]
    then
        echo "Python is enabled"
        spack install py-mochi-all
    else
        spack install mochi-all
    fi
elif [[ $BUILD_TYPE = "develop" ]]
then
    if [[ $ENABLE_PYTHON = "python" ]]
    then
        echo "Python is enabled"
        spack install py-mochi-all@develop
    else
        spack install mochi-all@develop
    fi
else
    echo "Invalid build type (should be release of develop)"
    exit 1
fi
