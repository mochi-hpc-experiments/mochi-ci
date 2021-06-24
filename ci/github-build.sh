#!/bin/bash

HERE=`dirname "$0"`

STATUS=0

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
  if [[ $VERSION = "develop" ]] ; then
    DEVELOP=true
  elif [[ $VERSION = "release" ]] ; then
    DEVELOP=false
  else
    echo "Verion should be either 'develop' or 'release'"
  fi
  RET=0
  spack env create $SPACKENV ci/github-env.yaml
  spack env activate $SPACKENV
  if $DEVELOP ; then
    spack add $PACKAGE@develop
    spack install
    RET=$?
  else
    spack add $PACKAGE
    spack install
    RET=$?
  fi
  if [[ "$RET" = "0" ]]; then
    printf "%-40s => OK\n" "$PACKAGE ($VERSION)" >> $LOGFILE
  else
    printf "%-40s => FAILURE\n" "$PACKAGE ($VERSION)" >> $LOGFILE
    STATUS=1
  fi
  spack env deactivate
  spack env rm -y $SPACKENV
}

echo "Loading Spack"
. /opt/spack/bin/spack/share/spack/setup-env.sh

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
  try_build mochi-sonata       $BUILD_TYPE $LOGFILE
  try_build mochi-bedrock      $BUILD_TYPE $LOGFILE
  try_build py-mochi-margo     $BUILD_TYPE $LOGFILE
  try_build py-mochi-bake      $BUILD_TYPE $LOGFILE
  try_build py-mochi-ssg       $BUILD_TYPE $LOGFILE
  try_build py-mochi-remi      $BUILD_TYPE $LOGFILE
  try_build py-mochi-sdskv     $BUILD_TYPE $LOGFILE
  try_build mobject            $BUILD_TYPE $LOGFILE

done

cat $LOGFILE

mailx -r mdorier@anl.gov -s "Daily Mochi build summary (Github)" sds-commits@lists.mcs.anl.gov < $LOGFILE

exit $STATUS
