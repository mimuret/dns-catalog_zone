#!/bin/bash
#
# add yadifad.conf
# >> include catlog.conf
#
if [ "$YADIFA_CONF_DIR" = "" ] ; then
  NSD_DIR='/usr/local/etc'
fi
if [ "$CATZ" = "" ] ; then
  CATZ='bundle exec catz'
fi
if [ "$YADIFA" = "" ] ; then
  YADIFA='yadifa'
fi

conf=$YADIFA_CONF_DIR/catlog.conf
new_conf=$YADIFA_CONF_DIR/catlog.conf.new

$CATZ make $1 > new_conf
if [ $? -eq 0 ] && `diff $new_conf $conf`  ; then
    mv $new_conf $conf
    $YADIFA cfgreload
fi
