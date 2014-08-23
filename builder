#!/bin/bash
START="$(date +%s)"

DATE=`date +%Y%m%d.%H%M%S`

CL_RED="\033[31m"
CL_GRN="\033[32m"
CL_YLW="\033[33m"
CL_BLU="\033[34m"
CL_MAG="\033[35m"
CL_CYN="\033[36m"
CL_RST="\033[0m"

if [ "$DEVICE" == "" ]; then
if [ "$1" != "" ]; then
DEVICE=$1
fi
fi
if [ "$DEVICE" == "" ]; then
echo -e "Abort: no device set" >&2
exit 0
fi

if [ "$ROM" == "" ]; then
if [ "$2" != "" ]; then
ROM=$2
fi
fi
if [ "$ROM" == "" ]; then
echo -e "Abort: no rom set" >&2
exit 0
fi

USER_CONFIG=~/.builder_configs/config
USER_CONFIG_DIR=~/.builder_configs/
if [ -e $USER_CONFIG ]
then
echo
else
mkdir $USER_CONFIG_DIR
echo -e "Enter your username:"
echo
read -r USERNAME
echo "USER=$USERNAME" >> "$USER_CONFIG"
echo
fi;
clear

echo -e "Enter build variant:"
echo
read -r VARIANT
echo
clear

if pwd |grep -q $ROM ; then
    name=$ROM
    repo=$ROM
    echo -e Building $ROM!
fi;

if pwd |grep -q eos ; then
    name=full
    repo=eos
fi;

if pwd |grep -q gummy ; then
    name=tg
    repo=gummy
fi;

if pwd |grep -q aosb ; then
    name=cm
    repo=aosb
fi;

. $USER_CONFIG
cd /home/$USER/$repo
source /home/$USER/$repo/build/envsetup.sh

lunch ${name}_$DEVICE-$VARIANT

OUT=~/$repo/out/target/product/$DEVICE
OUTPUT=~/$repo/out/target/product/$DEVICE/*"${name}"*.zip

echo -e "Do you want to clean the outdir?"
echo -e "[1] YES"
echo -e "[2] NO"
echo

echo -e "Enter your choice:"
read -n1 yesorno
echo
        if [[ "$yesorno" == "1" ]]; then
                echo -e "Clobbering!"
                make clobber -j40
        elif [[ "$yesorno" == "2" ]]; then
                echo -e "Continuing build!"
fi
clear
echo

echo -e  "Here we go!"

if [ $ROM == gummy ]; then
   echo -e "\e[94mYou are building $ROM!\e[39m"
   time mka -j40 gummy 2>&1 | tee $repo-$name_$DEVICE-$DATE.log
else
   echo -e "\e[96mYou are building $ROM!\e[39m"
   time mka -j40 bacon 2>&1 | tee $repo-$name_$DEVICE-$DATE.log
fi;

END="$(date +%s)"

DURATION="$(( $END - $START ))"
DURATION_MIN="$((DURATION/60))"

echo -e
echo -e $CL_CYN"===========-$repo-$TARGET_PRODUCT-$VARIANT build info-==========="$CL_RST
echo -e $CL_RST"duration: $DURATION_MIN minutes"$CL_RST
echo -e $CL_RST"log: "$repo"-"$name"_"$DEVICE"-"$DATE".log"$CL_RST
echo -e $CL_CYN"========================================"$CL_RST

exit 0
