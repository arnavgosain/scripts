#!/bin/bash
BUILDTYPE=UNOFFICIAL
DATE=`date +%Y%m%d`
ZIPOUT=out/target/product/nicki
DELTAOUT=~/delta/publish/nicki
ZIP=cm-11-$DATE-$BUILDTYPE-nicki.zip
DELTA=cm-11-$DATE-$BUILDTYPE-nicki.delta
SIGN=cm-11-$DATE-$BUILDTYPE-nicki.sign
UPDATE=cm-11-$DATE-$BUILDTYPE-nicki.update

function sync {
		repo sync -f -c -j32
}

function delta {
		source /home/nolinuxnoparty/delta/opendelta.sh nicki
		lftp -u arnavg.s,synergyDEV2014 -e "cd cm/nicki/delta;put $DELTAOUT/$DELTA;put $DELTAOUT/$SIGN; put $DELTAOUT/$UPDATE;quit" s.basketbuild.com
}

source build/envsetup.sh
breakfast nicki
make clobber
time make bacon -j21
lftp -u arnavg.s,synergyDEV2014 -e "cd cm/nicki/zip;put $ZIPOUT/$ZIP;quit" s.basketbuild.com
