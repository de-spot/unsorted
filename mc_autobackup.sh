#!/bin/bash
MCSCREEN=3
MCDIR=.
MCBACKUP=./backup
MCWORLD=world
function mc_backup() {
	local FBASENAME=`date +%Y%m%d_%H%M`
	local FNAME=${FBASENAME}.tgz
	local FARCHIVE=$MCBACKUP/$FNAME
	local FARCHIVEABS=`readlink -f $FARCHIVE`
	echo "`date "+%Y-%m-%d %H:%M"` Backup will archive $MCDIR/$MCWORLD to $FARCHIVEABS..."
	echo "`date "+%Y-%m-%d %H:%M"` Querying MC in screen $MCSCREEN to save world..."
	screen -p $MCSCREEN -X stuff "say Backup starting. World no longer saving!... $(printf '\r')"
	screen -p $MCSCREEN -X stuff "save-off $(printf '\r')"
	screen -p $MCSCREEN -X stuff "save-all $(printf '\r')"
	echo "`date "+%Y-%m-%d %H:%M"` Syncing..."
	sleep 3
	sync;sync;sync;sync
	sleep 2
	sync;sync;sync;sync
	local TMPDIR=$MCBACKUP/temp_$FBASENAME
	mkdir -p $TMPDIR
	echo "`date "+%Y-%m-%d %H:%M"` Copying $MCWORLD to $TMPDIR..."
	cp -a $MCDIR/$MCWORLD $TMPDIR/$MCWORLD
	echo "`date "+%Y-%m-%d %H:%M"` Syncing..."
	sync;sync;sync;sync
	echo "`date "+%Y-%m-%d %H:%M"` Enabling MC write..."
	screen -p $MCSCREEN -X stuff "save-on $(printf '\r')"
	screen -p $MCSCREEN -X stuff "say Backup complete! World now saving. $(printf '\r')"
	echo "`date "+%Y-%m-%d %H:%M"` Archiving..."
	echo "`date "+%Y-%m-%d %H:%M"` Command: cd $TMPDIR; tar -cpzf $FARCHIVEABS $MCWORLD"
	(cd $TMPDIR; tar -cpzf $FARCHIVEABS $MCWORLD)

	echo "`date "+%Y-%m-%d %H:%M"` Removing $MCBACKUP/temp_$FBASENAME"
	(cd $MCBACKUP && rm -rf temp_$FBASENAME)
	echo "`date "+%Y-%m-%d %H:%M"` Backup file: `ls -ld $FARCHIVE`"
}

echo "Minecraft backup tool v 0.1"

SLEEPTIME=0
if [ "$1" != "" ]; then
	SLEEPTIME=$1
fi

if [ $SLEEPTIME -gt 0 ]; then
	SLEEPSECONDS=$(($SLEEPTIME*60))
	echo "`date "+%Y-%m-%d %H:%M"` MC Backup: running each $SLEEPTIME minutes, first time right now."
	mc_backup
	while true; do
		echo "`date "+%Y-%m-%d %H:%M"` MC Backup: Sleeping $SLEEPSECONDS seconds..."
		sleep $SLEEPSECONDS
		echo "`date "+%Y-%m-%d %H:%M"` MC Backup: Backup time!"
		mc_backup
	done
else
	echo "`date "+%Y-%m-%d %H:%M"` MC Backup: single-run mode."
	mc_backup
fi

