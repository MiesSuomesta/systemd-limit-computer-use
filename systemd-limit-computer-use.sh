#!/bin/sh

func_get_str_date_from_epoch() {
	date +"%H:%M %d.%m.%Y" -d "@$1"
}


config=/etc/default/computer-use-disabled-hours.config

SYSTEM_SHUTDOWN_AT="23:00"
SYSTEM_USED_ALLOW_FROM="03:00"
TIMEOUT_MINUTES=30
TIMEOUT_MS=$(( ${TIMEOUT_MINUTES}*60*1000 ))
TIMEOUT_SEC=$(( ${TIMEOUT_MINUTES}*60 ))

if [ -e $config ]
then
	source $config
fi

# tmp file
TS_SAVE="/usr/local/tmp/systemd-computer-start-time.config"

TS_SHUTDOWN_AT=$(date +"%s" -d "$SYSTEM_SHUTDOWN_AT today")

TS_SYSTEM_USED_ALLOW_FROM_TD=$(date +"%s" -d "$SYSTEM_USED_ALLOW_FROM today")
TS_SYSTEM_USED_ALLOW_FROM_ND=$(date +"%s" -d "$SYSTEM_USED_ALLOW_FROM next day")

if [ -e ${TS_SAVE}  ];then
	source ${TS_SAVE}
else
	echo "TS_SHUTDOWN_AT=${TS_SHUTDOWN_AT}" > ${TS_SAVE}
	echo "TS_SYSTEM_USED_ALLOW_FROM_TD=${TS_SYSTEM_USED_ALLOW_FROM_TD}" >> ${TS_SAVE}
	echo "TS_SYSTEM_USED_ALLOW_FROM_ND=${TS_SYSTEM_USED_ALLOW_FROM_ND}" >> ${TS_SAVE}
fi

TS_NOW=$(date +"%s")

DATE_TS_TODAY=$(func_get_str_date_from_epoch $TS_SHUTDOWN_AT)

YEA=0
if [ $TS_NOW -gt $TS_SHUTDOWN_AT ]
then

	if [ $TS_NOW -lt $TS_SYSTEM_USED_ALLOW_FROM_TD ]
	then
		YEA=1
		DATE_TS_NEXTDAY=$(func_get_str_date_from_epoch $TS_SYSTEM_USED_ALLOW_FROM_TD)

	else
		if [ $TS_NOW -lt $TS_SYSTEM_USED_ALLOW_FROM_ND ]
		then
			YEA=2
			DATE_TS_NEXTDAY=$(func_get_str_date_from_epoch $TS_SYSTEM_USED_ALLOW_FROM_ND)
		fi
	fi
fi



if [ $YEA -gt 0 ]
then
	TO=$((${TS_NOW} + ${TIMEOUT_SEC}))
	DATE_TS_SD=$(func_get_str_date_from_epoch $TO)
	msgA="Shutdown at ${DATE_TS_SD}. Computer is not usable until $DATE_TS_NEXTDAY next day"
	msgB="\nCancel shutdown via: shutdown -c"

	notify-send -a "Sleep rythm enforcer" -t $TIMEOUT_MS "Shutting down in ${TIMEOUT_MINUTES} minutes."  "${msgA}${msgB}"
	logger -t "Sleep rythm enforcer" "$msgA"
	rm $TS_SAVE
	shutdown -Pf "+$TIMEOUT_MINUTES" "$msgA"
fi

#fail tp restart by systemd
exit 1

