#!/bin/bash
set -e

HERE=`dirname "$0"`

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
