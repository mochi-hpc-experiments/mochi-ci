#!/bin/bash
set -e

HERE=`dirname "$0"`

BUILD_TYPE=${1:-release}
ENABLE_PYTHON=${2:-none}

echo "Loading Spack"
. spack/share/spack/setup-env.sh

echo "Building all Mochi components (${BUILD_TYPE})"
if [[ $BUILD_TYPE = "release" ]]
then
    spack install mochi-all
    if [[ $ENABLE_PYTHON = "python" ]]
    then
        echo "Python is enabled"
    fi
elif [[ $BUILD_TYPE = "develop" ]]
then
    spack install mochi-all@develop
    if [[ $ENABLE_PYTHON = "python" ]]
    then
        echo "Python is enabled"
        spack install py-mochi-all@develop
    fi
else
    echo "Invalid build type (should be release of develop)"
    exit 1
fi
