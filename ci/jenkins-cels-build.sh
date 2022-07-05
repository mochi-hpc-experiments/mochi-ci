#!/bin/bash

source ~/.bashrc > /dev/null 2>&1

HERE=`dirname "$0"`

STATUS=0

function find_latest_version {
  echo $(spack info $1 | grep -A1 Preferred | tail -n1 | awk '{ print $1 }')
}

function try_build {
  PACKAGE=$1
  SPACKENV=$1-env
  VERSION=$2
  LOGFILE=$3
  DEVELOP=false
  echo "#######################################################" | tee -a full-log.txt
  echo "#######################################################" | tee -a full-log.txt
  echo "#######################################################" | tee -a full-log.txt
  echo "Building $PACKAGE ($VERSION version)" | tee -a full-log.txt
  RET=0
  spack env create $SPACKENV ci/cels-env.yaml | tee -a full-log.txt
  spack env activate $SPACKENV
  spack repo add mochi-spack-packages | tee -a full-log.txt
  if [[ $VERSION = "develop" ]] ; then
    DEVELOP=true
  elif [[ $VERSION = "release" ]] ; then
    DEVELOP=false
    VERSION=$(find_latest_version $PACKAGE)
  else
    echo "Verion should be either 'develop' or 'release'" | tee -a full-log.txt
  fi
  spack add $PACKAGE@$VERSION | tee -a full-log.txt
  spack install | tee -a full-log.txt
  RET=$?
  if [[ "$RET" = "0" ]]; then
    printf "%-40s => OK\n" "$PACKAGE ($VERSION)" >> $LOGFILE
  else
    printf "%-40s => FAILURE\n" "$PACKAGE ($VERSION)" >> $LOGFILE
    STATUS=1
  fi
  spack env deactivate
  spack env rm -y $SPACKENV | tee -a full-log.txt
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
  try_build mochi-sonata       $BUILD_TYPE $LOGFILE
  try_build mochi-bedrock      $BUILD_TYPE $LOGFILE
  try_build py-mochi-margo     $BUILD_TYPE $LOGFILE
  try_build py-mochi-bake      $BUILD_TYPE $LOGFILE
  try_build py-mochi-ssg       $BUILD_TYPE $LOGFILE
  try_build py-mochi-remi      $BUILD_TYPE $LOGFILE
  try_build mochi-yokan        $BUILD_TYPE $LOGFILE
  try_build py-mochi-sdskv     $BUILD_TYPE $LOGFILE
  try_build mobject            $BUILD_TYPE $LOGFILE
#  try_build mochi-sdsdkv       $BUILD_TYPE $LOGFILE
#  prepare_python
#  try_build py-mochi-tmci      $BUILD_TYPE $LOGFILE

done

cat $LOGFILE | tee -a full-log.txt

echo -e "\nYou can find build logs at $BUILD_URL" >> $LOGFILE

tar czvf full-log.tgz full-log.txt

mailx -r mdorier@anl.gov -s "Daily Mochi build summary (MCS workstation)" -A full-log.tgz sds-commits@lists.mcs.anl.gov < $LOGFILE

exit $STATUS
