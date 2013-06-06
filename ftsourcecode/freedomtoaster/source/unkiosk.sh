#!/bin/sh
/etc/init.d/freedom-toaster-x stop
rm -rf /home/kiosk/.mozilla
/etc/init.d/freedom-toaster-x start
