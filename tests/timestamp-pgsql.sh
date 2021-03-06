#!/bin/bash
# add 2018-06-27 by Pascal Withopf, released under ASL 2.0
. ${srcdir:=.}/diag.sh init
generate_conf
add_conf '
module(load="../plugins/imtcp/.libs/imtcp")
input(type="imtcp" port="0" listenPortFileName="'$RSYSLOG_DYNNAME'.tcpflood_port")

template(name="outfmt" type="string" string="%timestamp:::date-pgsql%\n")

:syslogtag, contains, "su" action(type="omfile" file=`echo $RSYSLOG_OUT_LOG`
				   template="outfmt")


'
startup
tcpflood -m1 -M "\"<34>1 2003-01-23T12:34:56.003Z mymachine.example.com su - ID47 - MSG\""
shutdown_when_empty
wait_shutdown

echo '2003-01-23 12:34:56' | cmp - $RSYSLOG_OUT_LOG
if [ ! $? -eq 0 ]; then
  echo "invalid response generated, $RSYSLOG_OUT_LOG is:"
  cat $RSYSLOG_OUT_LOG
  error_exit  1
fi;

exit_test
