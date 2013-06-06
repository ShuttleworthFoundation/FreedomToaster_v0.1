#!/bin/sh
#
# Originally based on:
# Version:      @(#)skeleton  1.8  03-Mar-1998  miquels@cistron.nl
#
# Modified for gdm, Steve Haslam <steve@arise.dmeon.co.uk> 14mar99
# modified to remove --exec, as it does not work on upgrades. 18jan2000
# modified to use --name, to detect stale PID files 18mar2000
# sleep until gdm dies, then restart it 16jul2000
# get along with other display managers (Branden Robinson, Ryan Murray) 05sep2001
# Modified for Kiosk, Stefano Rivera (http://rivera.za.net) 10 May 2006

set -e

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/local/sbin/freedom-toaster-x
USER=kiosk
PIDFILE=/var/run/freedom-toaster-x.pid
UPGRADEFILE=/var/run/freedom-toaster-x.upgrade

test -x $DAEMON || exit 0

if [ -r /etc/environment ]; then
  if LANG=$(pam_getenv -l LANG); then
    export LANG
  fi
fi

. /lib/lsb/init-functions

case "$1" in
  start)
        # if usplash is runing, make sure to stop it now
        if pidof usplash > /dev/null; then
                /etc/init.d/usplash stop
        fi
        log_begin_msg "Starting Freedom Toaster Kiosk..."
        start-stop-daemon --start --quiet --pidfile $PIDFILE --startas $DAEMON --background \
                -- $DAEMON >/dev/null 2>&1 || log_end_msg 1
        log_end_msg 0
  ;;
  stop)
        log_begin_msg "Stopping Freedom Toaster Kiosk..."
        start-stop-daemon --stop  --quiet --pidfile $PIDFILE --retry 30 >/dev/null 2>&1 || \
                log_success_msg "Freedom Toaster Kiosk not running"
        log_end_msg 0
  ;;
  restart|force-reload)
        $0 stop || true
        echo "Sleeping for 2 seconds..."
        sleep 2s
        $0 start
  ;;
  *)
        log_success_msg "Usage: /etc/init.d/freedomtoaster-kiosk {start|stop|restart|force-reload}"
        exit 1
  ;;
esac

exit 0
