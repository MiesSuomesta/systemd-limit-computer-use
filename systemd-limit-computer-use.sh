#!/bin/sh
config=/etc/default/computer-use-disabled-hours.config

SYSTEM_SHUTDOWN_AT="23:00"
SYSTEM_USED_ALLOW_FROM="05:00"
TIMEOUT_SECS=15
TIMEOUT_MS=$((${TIMEOUT_SECS}*1000))

if [ -e $config ]
then
	source $config
fi

TS_SAVE="/tmp/systemd-computer-start-time.config"

TS_SHUTDOWN_AT=$(date +"%s" -d "$SYSTEM_SHUTDOWN_AT today")
TS_SYSTEM_USED_ALLOW_FROM=$(date +"%s" -d "$SYSTEM_USED_ALLOW_FROM next day")

if [ -e  ];then
	source ${TS_SAVE}
else
	echo "TS_SHUTDOWN_AT=${TS_SHUTDOWN_AT}" > ${TS_SAVE}
	echo "TS_SYSTEM_USED_ALLOW_FROM=${TS_SYSTEM_USED_ALLOW_FROM}" >> ${TS_SAVE}
fi

TS_NOW=$(date +"%s")

func_get_str_date_from_epoch() {
	date +"%H:%M %d.%m.%Y" -d "@$1"
}

DATE_TS_TODAY=$(func_get_str_date_from_epoch $TS_SHUTDOWN_AT)
DATE_TS_NEXTDAY=$(func_get_str_date_from_epoch $TS_SYSTEM_USED_ALLOW_FROM)

if [ $TS_NOW -gt $TS_SHUTDOWN_AT -a $TS_NOW -lt $TS_SYSTEM_USED_ALLOW_FROM ]
then
	msg="shutdown at $DATE_TS_TODAY today and computer is not usable until $DATE_TS_NEXTDAY next day"

	notify-send -t $TIMEOUT_MS "Shutting down in $TIMEOUT !!"  "$msg"
	logger -s -t "$msg"
	shutdown -Pf +$TIMEOUT "$msg"
	while true
	do
		sleep 10
	done
fi

#fail tp restart by systemd
exit 1

