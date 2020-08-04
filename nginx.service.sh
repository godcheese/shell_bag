#! /bin/sh
# chkconfig: - 85 15

PATH=/web/server/nginx/sbin

DESC="nginx daemon"
NAME=nginx
DAEMON=/web/server/nginx/sbin/$NAME
CONFIGFILE=/web/server/nginx/conf/$NAME.conf
PIDFILE=/web/server/nginx/logs/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

set -e
[ -x "$DAEMON" ] || exit 0

do_start() {
$DAEMON -c $CONFIGFILE || echo -n "nginx already running"
}

do_stop() {
$DAEMON -s stop || echo -n "nginx not running"
}

do_reload() {
$DAEMON -s reload || echo -n "nginx can't reload"
}

case "$1" in
start)
echo -n "Starting $DESC: $NAME"
do_start
echo "."
;;
stop)
echo -n "Stopping $DESC: $NAME"
do_stop
echo "."
;;
reload|graceful)
echo -n "Reloading $DESC configuration..."
do_reload
echo "."
;;
restart)
echo -n "Restarting $DESC: $NAME"
do_stop
do_start
echo "."
;;
*)
echo "Usage: $SCRIPTNAME {start|stop|reload|restart}" >&2
exit 3
;;
esac

exit 0