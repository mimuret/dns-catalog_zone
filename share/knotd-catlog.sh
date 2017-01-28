#!/bin/bash
#
# add yadifad.conf
# >> include catlog.conf
#
DNS_CATLOG_ZONE_DIR='/usr/local/dns-catlog_zone'
KNOT_CONF_DIR='/usr/local/etc/knot'
CONF=$DNS_CATLOG_ZONE_DIR/catlog-zone.conf
KNOTC='/var/service/ans/knot/sbin/knotc'

if [ -e /etc/sysconfig/dns-catlog_zone ] ; then
 . /etc/sysconfig/dns-catlog_zone
fi

# zone flush to file
$KNOTC zone-flush

# make config
cd $DNS_CATLOG_ZONE_DIR
bundle exec catz make $1 > $CONF.new 2>/dev/null

if [ $? -eq 0 ] ; then
    diff $CONF.new $CONF > /dev/null 2>&1
    if [ $? -ne 0 ] ; then 
      echo "reconfig"
      mv $CONF.new $CONF
      $KNOTC conf-check
      if [ $? -eq 0 ] ; then
        $KNOTC reload
      fi
    fi
fi

if [ -e $CONF.new ] ; then
  rm $CONF.new
fi
