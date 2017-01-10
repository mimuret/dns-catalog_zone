#!/bin/bash
#
# add nsd.conf
# >> include: catlog.conf
#

if [ "$NSD_DIR" = "" ] ; then
  NSD_DIR='/etc/nsd'
fi
if [ "$CATZ" = "" ] ; then
  CATZ='bundle exec catz'
fi
if [ "$NSD_CHECKCONF" = "" ] ; then
  NSD_CHECKCONF='nsd-checkconf'
fi
if [ "$NSD_CONTROL" = "" ] ; then
  NSD_CONTROL='nsd-control'
fi

conf=$NSD_COONF_DIR/catlog.conf
new_conf=$NSD_COONF_DIR/catlog.conf.new


$CATZ make $1 > new_conf
if [ $? -eq 0 ] && `diff $new_conf $conf` ; then
    mv $new_conf $conf
    $NSD_CHECKCONF $NSD_DIR/nsd.conf
    if [ $? -eq 0 ] ; then
        $NSD_CONTROL reconfig
    fi
fi
