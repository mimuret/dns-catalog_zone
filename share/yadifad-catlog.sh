#!/bin/bash
#
# add yadifad.conf
# >> include catlog.conf
#
DNS_CATLOG_ZONE_DIR='/usr/local/dns-catlog_zone'
YADIFA_CONF_DIR='/usr/local/etc'
PID_FILE=/var/run/yadifad/yadifa.pid
CONF=$YADIFA_CONF_DIR/catlog-zone.conf

# write zonefile
if [ -e "$PID_FILE" ] ; then
  kill -USR1 `cat $PID_FILE`
fi
# make config
cd $DNS_CATLOG_ZONE_DIR
bundle exec catz make $1 > $CONF.new 2>/dev/null

if [ $? -eq 0 ] ; then
    diff $CONF.new $CONF > /dev/null 2>&1
    if [ $? -ne 0 ] ; then 
      echo "reconfig"
      mv $CONF.new $CONF
      systemctl restart yadifad
    fi
fi

if [ -e $CONF.new ] ; then
  rm $CONF.new
fi
