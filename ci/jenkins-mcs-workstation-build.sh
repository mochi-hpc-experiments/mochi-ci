#!/bin/bash

HERE=`dirname "$0"`

STATUS=0

function try_build {
  COMPILER=$1
  PACKAGE=$2
  SPACKENV=$2-env
  VERSION=$3
  LOGFILE=$4
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
  spack env create $SPACKENV ci/mcs-workstation-env.yaml
  spack env activate $SPACKENV
  if $DEVELOP ; then
    spack add $PACKAGE@develop %$COMPILER
  else
    spack add $PACKAGE %$COMPILER
  fi
  if [[ $COMPILER == clang* ]]; then
    spack add mpich~fortran
  fi
  spack install
  RET=$?
  if [[ "$RET" = "0" ]]; then
    printf "%-40s => OK\n" "$PACKAGE ($VERSION - $COMPILER)" >> $LOGFILE
  else
    printf "%-40s => FAILURE\n" "$PACKAGE ($VERSION - $COMPILER)" >> $LOGFILE
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

echo "Loading Spack"
. spack/share/spack/setup-env.sh

LOGFILE=build.txt

for COMPILER in "gcc@9.1.0" # "clang@8.0.0"
do
for BUILD_TYPE in release develop
do

  echo "========== ${BUILD_TYPE} =========" >> $LOGFILE
  echo "Building all Mochi components (${BUILD_TYPE})"
  try_build $COMPILER mochi-mona         $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-abt-io       $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-margo        $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-ch-placement $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-thallium     $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-ssg          $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-colza        $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-bake         $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-sdskv        $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-remi         $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-poesie       $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-sonata       $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-bedrock      $BUILD_TYPE $LOGFILE
  try_build $COMPILER py-mochi-margo     $BUILD_TYPE $LOGFILE
  try_build $COMPILER py-mochi-bake      $BUILD_TYPE $LOGFILE
  try_build $COMPILER py-mochi-ssg       $BUILD_TYPE $LOGFILE
  try_build $COMPILER py-mochi-remi      $BUILD_TYPE $LOGFILE
  try_build $COMPILER mochi-yokan        $BUILD_TYPE $LOGFILE
  try_build $COMPILER py-mochi-sdskv     $BUILD_TYPE $LOGFILE
  try_build $COMPILER mobject            $BUILD_TYPE $LOGFILE
#  try_build mochi-sdsdkv       $BUILD_TYPE $LOGFILE
#  prepare_python
#  try_build py-mochi-tmci      $BUILD_TYPE $LOGFILE

done
done

cat $LOGFILE

echo -e "\nYou can find build logs at $BUILD_URL" >> $LOGFILE

mailx -r mdorier@anl.gov -s "Daily Mochi build summary (MCS workstation)" sds-commits@lists.mcs.anl.gov < $LOGFILE

exit $STATUS
