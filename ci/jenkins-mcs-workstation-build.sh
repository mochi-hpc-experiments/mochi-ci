#!/bin/bash

HERE=`dirname "$0"`

BUILD_TYPE=${1:-release}
ENABLE_PYTHON=${2:-none}

STATUS=0

function try_build {
  PACKAGE=$1
  DEVELOP=$2
  if [[ $DEVELOP = "develop" ]] ; then
    DEVELOP=true
  elif [[ $DEVELOP = "release" ]] ; then
    DEVELOP=false
  else
    echo "Verion should be either 'develop' or 'release'"
  fi
  LOGFILE=$PACKAGE-$DEVELOP.log
  echo "####################################" >> $LOGFILE
  echo "Package $PACKAGE ($DEVELOP)"          >> $LOGFILE
  echo "####################################" >> $LOGFILE
  RET=0
  if $DEVELOP ; then
    spack install $PACKAGE@develop 2>&1 >> $LOGFILE
    RET=$!
  else
    spack install $PACKAGE 2>&1 >> $LOGFILE
    RET=$!
  fi
  if [ $RET -eq 0 ]; then
    echo "$PACKAGE ($DEVELOP) build => OK"
  else
    echo "$PACKAGE ($DEVELOP) build => FAILURE"
    STATUS=1
  fi
}

echo "Loading Spack"
. spack/share/spack/setup-env.sh

mkdir build-errors

echo "Building all Mochi components (${BUILD_TYPE})"
try_build mochi-abt-io       $BUILD_TYPE
try_build mochi-margo        $BUILD_TYPE
try_build mochi-ch-placement $BUILD_TYPE
try_build mochi-thallium     $BUILD_TYPE
try_build mochi-ssg          $BUILD_TYPE
try_build mochi-bake         $BUILD_TYPE
try_build mochi-sdskv        $BUILD_TYPE
try_build mochi-remi         $BUILD_TYPE
try_build mochi-poesie       $BUILD_TYPE
try_build mochi-mdcs         $BUILD_TYPE
try_build mochi-sdsdkv       $BUILD_TYPE
try_build mochi-abt-io       $BUILD_TYPE

if [ $ENABLE_PYTHON = "python" ]; then
  try_build py-mochi-margo $BUILD_TYPE
  try_build py-mochi-bake  $BUILD_TYPE
  try_build py-mochi-ssg   $BUILD_TYPE
  try_build py-mochi-remi  $BUILD_TYPE
  try_build py-mochi-sdskv $BUILD_TYPE
  try_build py-mochi-tmci  $BUILD_TYPE
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
