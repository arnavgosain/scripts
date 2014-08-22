#!/bin/bash
clear
echo -e "> [N O L I N U X N O P A R T Y] <"
echo
echo -e " Script to build almost any rom."
echo -e " Usage: ./builder <codename> <rom> <username> <build-variant>"
echo -e " For example: ./builder nicki vanir nolinuxnoparty userdebug"
echo
read -p "Press [Enter] key to continue..."
clear

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

if [ "$USER" == "" ]; then
if [ "$3" != "" ]; then
USER=$3
fi
fi
if [ "$USER" == "" ]; then
echo -e "Abort: no user set" >&2
exit 0
fi

if [ "$VARIANT" == "" ]; then
if [ "$4" != "" ]; then
VARIANT=$4
fi
fi
if [ "$VARIANT" == "" ]; then
echo -e "Abort: no build variant set" >&2
exit 0
fi

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

cd /home/$USER/$repo
source /home/$USER/$repo/build/envsetup.sh

lunch ${name}_$DEVICE-$VARIANT

OUT=~/$repo/out/target/product/$DEVICE
OUTPUT=~/$repo/out/target/product/$DEVICE/*${name}*.zip

echo -e "Do you want to clean the outdir?"
echo -e "[ 1 ] YES"
echo -e "[ 2 ] NO"

echo -e "Enter your choice:"
read yesorno
        if [[ "$yesorno" == "1" ]]; then
                echo -e "Clobbering!"
                make clobber -j40
        elif [[ "$yesorno" == "2" ]]; then
                echo -e "Continuing build!"
fi
clear

echo -e "Do you want to continue?"
echo -e "[ 1 ] YES"
echo -e "[ 2 ] NO"

echo -e "Enter your choice:"
read continue
        if [[ "$continue" == "1" ]]; then
                echo -e "Continuing further build process!"
        elif [[ "$continue" == "2" ]]; then
                echo -e "Exiting Script"
                exit 0
fi
clear

echo -e  "Here we go!"

if [ $ROM == gummy ]; then
   echo -e "\e[94mYou are building $ROM!\e[39m"
   time mka -j40 gummy 2>&1 | tee $repo-$name_$DEVICE-$DATE.log
else
   echo -e "\e[96mYou are building $ROM!\e[39m"
   time mka -j40 bacon 2>&1 | tee $repo-$name_$DEVICE-$DATE.log
fi;

#if [ -e $OUTPUT ]
#then
#  echo -e "\e[92mBuild succesfull!\e[39m"
#else
#  echo -e "\e[91mBuild failed!"
#  echo -e "$OUTPUT does not exist!\e[39m"
#fi;

#echo -e "Do you wish to enter outdir?"
#echo -e "[ 1 ] YES"
#echo -e "[ 2 ] NO"

#echo -e "Enter your choice:"
#read outdir
#        if [[ "$outdir" == "1" ]]; then
#                echo -e "Entering OUTDIR!"
#                cd $OUT
#        elif [[ "$outdir" == "2" ]]; then
#                END="$(date +%s)"
#
#                DURATION="$(( $END - $START ))"
#                DURATION_MIN="$((DURATION/60))"
#                echo -e "The build took $DURATION_MIN minutes"
#fi
END="$(date +%s)"

DURATION="$(( $END - $START ))"
DURATION_MIN="$((DURATION/60))"

if [ -e $OUTPUT ]
then
echo -e
echo -e $CL_CYN"===========-Build failed-==========="$CL_RST
echo -e $CL_RST"build duration: $DURATION_MIN minutes"$CL_RST
echo -e $CL_RST"build log: $repo-$name_$DEVICE-$DATE.log"$CL_RST
echo -e $CL_CYN"========================================"$CL_RST
else
echo -e
echo -e $CL_CYN"===========-Package complete-==========="$CL_RST
echo -e $CL_RST"build duration: $DURATION_MIN minutes"$CL_RST
echo -e $CL_RST"build log: $repo-$name_$DEVICE-$DATE.log"$CL_RST
echo -e $CL_CYN"========================================"$CL_RST
fi;

exit 0
