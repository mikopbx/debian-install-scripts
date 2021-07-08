#!/bin/bash

ln -s /etc/apparmor.d/usr.bin.msmtp /etc/apparmor.d/disable/
apparmor_parser -R /etc/apparmor.d/usr.bin.msmtp