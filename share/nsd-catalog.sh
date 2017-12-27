#!/bin/bash
#
# add yadifad.conf
# >> include catalog.conf
#
NSD_CONF_DIR='/etc/nsd'
NSD_CHECKCONF='/usr/local/sbin/nsd-checkconf'
NSD_CONTROL='/usr/local/sbin/nsd-control'
DNS_catalog_zone_DIR='/usr/local/dns-catalog_zone'
CONF='/etc/nsd/catalog-zone.conf'

if [ -e /etc/sysconfig/dns-catalog_zone ] ; then
 . /etc/sysconfig/dns-catalog_zone
fi

# zone flush to file
$NSD_CONTROL write

# make config
cd $DNS_catalog_zone_DIR
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
