#!/bin/bash

HERE=`dirname "$0"`

STATUS=0

function try_build {
  PACKAGE=$1
  VERSION=$2
  LOGFILE=$3
  DEVELOP=false
  echo "#######################################################"
  echo "#######################################################"
  echo "#######################################################"
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
    printf "%-40s => OK\n" "$PACKAGE ($VERSION)" >> $LOGFILE
  else
    printf "%-40s => FAILURE\n" "$PACKAGE ($VERSION)" >> $LOGFILE
    STATUS=1
  fi
}

function prepare_python {
  spack install py-pip
  spack load -r py-pip
  pip install 'tensorflow==2.1.0'
}

echo "Loading Spack"
. spack/share/spack/setup-env.sh

LOGFILE=build.txt

for BUILD_TYPE in release develop
do

  echo "========== ${BUILD_TYPE} =========" >> $LOGFILE
  echo "Building all Mochi components (${BUILD_TYPE})"
  try_build mochi-mona         $BUILD_TYPE $LOGFILE
  try_build mochi-abt-io       $BUILD_TYPE $LOGFILE
  try_build mochi-margo        $BUILD_TYPE $LOGFILE
  try_build mochi-ch-placement $BUILD_TYPE $LOGFILE
  try_build mochi-thallium     $BUILD_TYPE $LOGFILE
  try_build mochi-ssg          $BUILD_TYPE $LOGFILE
  try_build mochi-colza        $BUILD_TYPE $LOGFILE
  try_build mochi-bake         $BUILD_TYPE $LOGFILE
  try_build mochi-sdskv        $BUILD_TYPE $LOGFILE
  try_build mochi-remi         $BUILD_TYPE $LOGFILE
  try_build mochi-poesie       $BUILD_TYPE $LOGFILE
  try_build mochi-mdcs         $BUILD_TYPE $LOGFILE
  try_build mochi-sdsdkv       $BUILD_TYPE $LOGFILE
  try_build mochi-sonata       $BUILD_TYPE $LOGFILE
  try_build mochi-bedrock      $BUILD_TYPE $LOGFILE
  try_build py-mochi-margo     $BUILD_TYPE $LOGFILE
  try_build py-mochi-bake      $BUILD_TYPE $LOGFILE
  try_build py-mochi-ssg       $BUILD_TYPE $LOGFILE
  try_build py-mochi-remi      $BUILD_TYPE $LOGFILE
  try_build py-mochi-sdskv     $BUILD_TYPE $LOGFILE
#  prepare_python
#  try_build py-mochi-tmci      $BUILD_TYPE $LOGFILE

done

cat $LOGFILE

echo -e "\nYou can find build logs at $BUILD_URL" >> $LOGFILE

mailx -r mdorier@anl.gov -s "Daily Mochi build summary (MCS workstation)" sds-commits@lists.mcs.anl.gov < $LOGFILE

exit $STATUS
