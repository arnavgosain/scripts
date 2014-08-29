#!/bin/bash
START="$(date +%s)"

usage()
{
    echo -e ""
    echo -e ${txtbld}"Usage:"${txtrst}
    echo -e "  builder [options] rom_device-variant"
    echo -e ""
    echo -e ${txtbld}"  Options:"${txtrst}
    echo -e "    -c  Clean previous output before build."
    echo -e "    -j# Set jobs"
    echo -e "    -l  Log of the build output"
    echo -e "    -r  Reset source tree before build"
    echo -e "    -v  Verbose build output"
    echo -e ""
    echo -e ${txtbld}"  Example:"${txtrst}
    echo -e "    ./builder -c vanir_hammerhead-userdebug"
    echo -e ""
    exit 1
}

opt_clean=0
opt_jobs="$CPUS"
opt_reset=0
opt_verbose=0
opt_log=0

while getopts ":c:j:l:r:v" opt; do
    case "$opt" in
    c) opt_clean=1 ;;
    j) opt_jobs="$OPTARG" ;;
    l) opt_log=1 ;;
    r) opt_reset=1 ;;
    v) opt_verbose=1 ;;
    *) usage
    esac
done
shift $((OPTIND-1))
if [ "$#" -ne 1 ]; then
    usage
fi
build_combo="$1"

DATE=`date +%Y%m%d.%H%M%S`

CL_RED="\033[31m"
CL_GRN="\033[32m"
CL_YLW="\033[33m"
CL_BLU="\033[34m"
CL_MAG="\033[35m"
CL_CYN="\033[36m"
CL_RST="\033[0m"

source build/envsetup.sh
lunch "$build_combo"

# reset source tree
if [ "$opt_reset" -ne 0 ]; then
    echo -e ""
    echo -e ${bldblu}"Resetting source tree and removing all uncommitted changes"${txtrst}
    repo forall -c "git reset --hard HEAD; git clean -qf"
    echo -e ""
fi

if [ "$opt_clean" -eq 1 ]; then
    make clean
    make clobber
    make installclean
    echo -e ""
    echo -e ${bldblu}"Out is clean"${txtrst}
    echo -e ""
fi
clear

echo -e  "Here we go!"

if [ "$opt_log" -eq 0 ]; then
if [ "$opt_verbose" -ne 0 ]; then
	time make -j"$opt_jobs" showcommands bacon
else
	time mka -j"$opt_jobs" bacon
fi;
else
if [ "$opt_verbose" -ne 0 ]; then
        time make -j"$opt_jobs" showcommands bacon 2>&1 | tee $build_combo-$DATE.log
else
        time mka -j"$opt_jobs" bacon 2>&1 | tee $build_combo-$DATE.log
fi;
fi;

END="$(date +%s)"

DURATION="$(( $END - $START ))"
DURATION_MIN="$((DURATION/60))"

if [ "$opt_log" -ne 0 ]; then
echo -e
echo -e $CL_CYN"===========-$build_combo build info-==========="$CL_RST
echo -e $CL_RST"duration: $DURATION_MIN minutes"$CL_RST
echo -e $CL_CYN"========================================"$CL_RST
else
echo -e
echo -e $CL_CYN"===========-$build_combo build info-==========="$CL_RST
echo -e $CL_RST"duration: $DURATION_MIN minutes"$CL_RST
echo -e $CL_RST"log: "$build_combo-$DATE".log"$CL_RST
echo -e $CL_CYN"========================================"$CL_RST
fi;

exit 0
