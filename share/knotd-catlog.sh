#!/bin/bash
#
# add knot.conf
# >> include: catlog.conf
#

if [ "$KNOTD_COONF_DIR" = "" ] ; then
  NSD_DIR='/usr/local/etc/knot'
fi
if [ "$CATZ" = "" ] ; then
  CATZ='bundle exec catz'
fi
if [ "$KNOTC" = "" ] ; then
  KNOTC='knotc'
fi

conf=$KNOTD_COONF_DIR/catlog.conf
new_conf=$KNOTD_COONF_DIR/catlog.conf.new

$CATZ make $1 > $new_conf
if [ $? -eq 0 ] && `diff $conf $new_conf` ; then
    mv $new_conf $conf
    $KNOTC conf-check
    if [ $? -eq 0] ; then
      $KNOTC reload
    fi
fi
