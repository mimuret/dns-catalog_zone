#!/bin/bash
#
# add yadifad.conf
# >> include catlog.conf
#
NSD_CONF_DIR='/etc/nsd'
NSD_CHECKCONF='/usr/local/sbin/nsd-checkconf'
NSD_CONTROL='/usr/local/sbin/nsd-control'
DNS_CATLOG_ZONE_DIR='/usr/local/dns-catlog_zone'
CONF='/etc/nsd/catlog-zone.conf'

if [ -e /etc/sysconfig/dns-catlog_zone ] ; then
 . /etc/sysconfig/dns-catlog_zone
fi

# zone flush to file
$NSD_CONTROL write

# make config
cd $DNS_CATLOG_ZONE_DIR
bundle exec catz make $1 > $CONF.new 2>/dev/null

if [ $? -eq 0 ] ; then
    diff $CONF.new $CONF > /dev/null 2>&1
    if [ $? -ne 0 ] ; then 
      echo "reconfig"
      mv $CONF.new $CONF
      $NSD_CHECKCONF $NSD_CONF_DIR/nsd.conf
      if [ $? -eq 0 ] ; then
	$NSD_CONTROL reconfig
      fi
    fi
fi

if [ -e $CONF.new ] ; then
  rm $CONF.new
fi
