#!/bin/bash

HERE=`dirname "$0"`

BUILD_TYPE=${1:-release}
ENABLE_PYTHON=${2:-none}

STATUS=0

function try_build {
  PACKAGE=$1
  VERSION=$2
  LOGFILE=$3
  DEVELOP=false
  echo "Building $PACKAGE ($VERSION version)"
  if [[ $VERSION = "develop" ]] ; then
    DEVELOP=true
  elif [[ $VERSION = "release" ]] ; then
    DEVELOP=false
  else
    echo "Verion should be either 'develop' or 'release'"
  fi
  RET=0
  if $DEVELOP ; then
    spack install $PACKAGE@develop
    RET=$?
  else
    spack install $PACKAGE
    RET=$?
  fi
  if [[ "$RET" = "0" ]]; then
    echo "$PACKAGE ($VERSION) build => OK" >> $LOGFILE
  else
    echo "$PACKAGE ($VERSION) build => FAILURE" >> $LOGFILE
    STATUS=1
  fi
}

echo "Loading Spack"
. spack/share/spack/setup-env.sh

mkdir build-errors

LOGFILE=build.txt

echo "Building all Mochi components (${BUILD_TYPE})"
try_build mochi-abt-io       $BUILD_TYPE $LOGFILE
try_build mochi-margo        $BUILD_TYPE $LOGFILE
try_build mochi-ch-placement $BUILD_TYPE $LOGFILE
try_build mochi-thallium     $BUILD_TYPE $LOGFILE
try_build mochi-ssg          $BUILD_TYPE $LOGFILE
try_build mochi-bake         $BUILD_TYPE $LOGFILE
try_build mochi-sdskv        $BUILD_TYPE $LOGFILE
try_build mochi-remi         $BUILD_TYPE $LOGFILE
try_build mochi-poesie       $BUILD_TYPE $LOGFILE
try_build mochi-mdcs         $BUILD_TYPE $LOGFILE
try_build mochi-sdsdkv       $BUILD_TYPE $LOGFILE
try_build mochi-abt-io       $BUILD_TYPE $LOGFILE

if [ $ENABLE_PYTHON = "python" ]; then
  try_build py-mochi-margo $BUILD_TYPE $LOGFILE
  try_build py-mochi-bake  $BUILD_TYPE $LOGFILE
  try_build py-mochi-ssg   $BUILD_TYPE $LOGFILE
  try_build py-mochi-remi  $BUILD_TYPE $LOGFILE
  try_build py-mochi-sdskv $BUILD_TYPE $LOGFILE
  try_build py-mochi-tmci  $BUILD_TYPE $LOGFILE
fi

exit $STATUS

#if [[ $BUILD_TYPE = "release" ]]
#then
#    spack install --only dependencies mochi-all
#    if [[ $ENABLE_PYTHON = "python" ]]
#    then
#        echo "Python is enabled"
#        spack install --only dependencies py-mochi-all
#    fi
#elif [[ $BUILD_TYPE = "develop" ]]
#then
#    spack install --only dependencies mochi-all@develop
#    if [[ $ENABLE_PYTHON = "python" ]]
#    then
#        echo "Python is enabled"
#        spack install --only dependencies py-mochi-all@develop
#    fi
#else
#    echo "Invalid build type (should be release of develop)"
#    exit 1
#fi
