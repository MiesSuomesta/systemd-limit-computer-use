#!/bin/sh

sudo cp systemd-limit-computer-use.service /usr/lib/systemd/system/
sudo cp systemd-limit-computer-use.sh /usr/local/bin/
sudo cp systemd-limit-computer-use.config /etc/default/computer-use-disabled-hours

sudo systemctl enable systemd-limit-computer-use
sudo systemctl restart systemd-limit-computer-use

echo systemd installation done
