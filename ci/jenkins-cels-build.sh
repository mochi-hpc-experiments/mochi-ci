#!/bin/bash

source ~/.bashrc > /dev/null 2>&1

HERE=`dirname "$0"`

STATUS=0

export SPACK_DISABLE_LOCAL_CONFIG=true
export SPACK_USER_CACHE_PATH=$HOME/spack-cache

function find_latest_version {
  echo $(spack info $1 | grep -A1 Preferred | tail -n1 | awk '{ print $1 }')
}

function try_build {
  PACKAGE=$1
  SPACKENV=$1-env
  VERSION=$2
  LOGFILE=$3
  DEVELOP=false
  echo "#######################################################"
  echo "#######################################################"
  echo "#######################################################"
  echo "Building $PACKAGE ($VERSION version)"
  RET=0
  spack env create $SPACKENV ci/cels/spack.yaml
  RET=$?
  if [[ "$RET" != "0" ]]; then
    STATUS=1
    return
  fi
  spack env activate $SPACKENV
  RET=$?
  if [[ "$RET" != "0" ]]; then
    STATUS=1
    return
  fi
  spack repo add mochi-spack-packages
  RET=$?
  if [[ "$RET" != "0" ]]; then
    STATUS=1
    return
  fi
  if [[ $VERSION = "develop" ]] ; then
    DEVELOP=true
  elif [[ $VERSION = "release" ]] ; then
    DEVELOP=false
    VERSION=$(find_latest_version $PACKAGE)
  else
    echo "Version should be either 'develop' or 'release'"
  fi
  spack add $PACKAGE@$VERSION
  RET=$?
  if [[ "$RET" != "0" ]]; then
    STATUS=1
    return
  fi
  spack install
  RET=$?
  if [[ "$RET" = "0" ]]; then
    printf "%-40s => OK\n" "$PACKAGE ($VERSION)" >> $LOGFILE
  else
    printf "%-40s => FAILURE\n" "$PACKAGE ($VERSION)" >> $LOGFILE
    STATUS=1
  fi
  spack env deactivate
  spack env rm -y $SPACKENV
}

function prepare_python {
  spack install py-pip
  spack load -r py-pip
  pip install 'tensorflow==2.1.0'
}

echo "CI is running as user $USER"

echo "Loading Spack"
. spack/share/spack/setup-env.sh

LOGFILE=build.txt

for BUILD_TYPE in release develop
do

  echo "========== ${BUILD_TYPE} =========" >> $LOGFILE
  echo "Building all Mochi components (${BUILD_TYPE})"
#  try_build mochi-mona         $BUILD_TYPE $LOGFILE
  try_build mochi-abt-io       $BUILD_TYPE $LOGFILE
  try_build mochi-margo        $BUILD_TYPE $LOGFILE
  try_build py-mochi-margo     $BUILD_TYPE $LOGFILE
  try_build mochi-ch-placement $BUILD_TYPE $LOGFILE
  try_build mochi-thallium     $BUILD_TYPE $LOGFILE
  try_build mochi-bedrock      $BUILD_TYPE $LOGFILE
  try_build mochi-poesie       $BUILD_TYPE $LOGFILE
  try_build mochi-yokan        $BUILD_TYPE $LOGFILE
  try_build mochi-warabi       $BUILD_TYPE $LOGFILE
  try_build mochi-flock        $BUILD_TYPE $LOGFILE
  try_build mochi-quintain     $BUILD_TYPE $LOGFILE
#  try_build mochi-remi         $BUILD_TYPE $LOGFILE
#  try_build py-mochi-remi      $BUILD_TYPE $LOGFILE
#  try_build mochi-ssg          $BUILD_TYPE $LOGFILE
#  try_build py-mochi-ssg       $BUILD_TYPE $LOGFILE
#  try_build mochi-bake         $BUILD_TYPE $LOGFILE
#  try_build py-mochi-bake      $BUILD_TYPE $LOGFILE
#  try_build mochi-sdskv        $BUILD_TYPE $LOGFILE
#  try_build mochi-sonata       $BUILD_TYPE $LOGFILE
#  try_build mochi-colza        $BUILD_TYPE $LOGFILE
#  try_build py-mochi-sdskv     $BUILD_TYPE $LOGFILE
  try_build mofka              $BUILD_TYPE $LOGFILE
#  try_build mobject            $BUILD_TYPE $LOGFILE
#  try_build hepnos             $BUILD_TYPE $LOGFILE
#  try_build mochi-sdsdkv       $BUILD_TYPE $LOGFILE
#  prepare_python
#  try_build py-mochi-tmci      $BUILD_TYPE $LOGFILE

done

cat $LOGFILE

echo -e "\nYou can find build logs at $BUILD_URL" >> $LOGFILE

mailx -r mdorier@anl.gov -s "Daily Mochi build summary (MCS workstation)" sds-commits@lists.mcs.anl.gov < $LOGFILE

rm  -rf $HOME/spack-cache

exit $STATUS
