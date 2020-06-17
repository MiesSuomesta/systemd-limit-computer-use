#!/bin/sh
config=/etc/default/computer-use-disabled-hours.config

SYSTEM_SHUTDOWN_AT="23:00"
SYSTEM_USED_ALLOW_FROM="05:00"

if [ -e $config ]; then
	source config
fi

TS_NOW=$(date +"%s")
TS_SHUTDOWN_AT=$(date +"%s" -d "$SYSTEM_SHUTDOWN_AT today")
TS_SYSTEM_USED_ALLOW_FROM=$(date +"%s" -d "$SYSTEM_USED_ALLOW_FROM next day")

if [ $TS_NOW -gt $TS_SHUTDOWN_AT -a $TS_NOW -lt $TS_SYSTEM_USED_ALLOW_FROM ]
then
msg="shutdown at $SYSTEM_SHUTDOWN_AT today and computer is not usable until $SYSTEM_USED_ALLOW_FROM next day"

	notify-send "Shutting down in $TIMEOUT"  "$msg"
	logger -s -t "$msg"
	shutdown -Pf now "$msg"
else
	logger -s -t "use of computer" "Computer use allowed."
fi

#fail tp restart by systemd
exit 1

