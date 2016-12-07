#!/bin/bash
# --------------------------------------------------------------------------
# Wrapper script for btnap.service
#
# This script is a slightly pimped up version of the script found in
# the post by Mike Kazantsev (See CREDITS for details).
#
#
# Author: Bernhard Bablok
# License: GPL3
#
# Website: https://github.com/bablokb/pi-btnap
#
# --------------------------------------------------------------------------

source /etc/btnap.conf

# --- create bridge   ------------------------------------------------------

if [ "$MODE" = "server" ]; then
  if [ -n "$(brctl show $BR_DEV 2>&1 >/dev/null)" ]; then
     brctl addbr "$BR_DEV"
     brctl setfd "$BR_DEV" 0
     brctl stp "$BR_DEV" off
     ip addr add "$BR_IP" dev "$BR_DEV"
     [ -n "$ADD_IF" ] && brctl addif "$BR_DEV" "$ADD_IF"
     ip link set "$BR_DEV" up
     [ -n "$BR_GW" ] && ip route add default via "$BR_GW" dev "$BR_DEV"
  fi
fi

# --- start service-script -------------------------------------------------

if [ "$MODE" = "server" ]; then
  exec /usr/local/sbin/btnap.service.py ${DEBUG:+--debug} server $BR_DEV
else
  exec /usr/local/sbin/btnap.service.py ${DEBUG:+--debug} client $REMOTE_DEV
fi
