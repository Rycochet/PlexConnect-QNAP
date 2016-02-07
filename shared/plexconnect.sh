#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="PlexConnect"
QPKG_ROOT=`/sbin/getcfg ${QPKG_NAME} Install_Path -f ${CONF}`

function update_conf()
{
	OLD_VALUE=`/sbin/getcfg ${QPKG_NAME} $1 -f ${PLEXCONNECT_CONF}`
	NEW_VALUE=`/sbin/getcfg ${QPKG_NAME} $1 -f ${QPKG_CONF}`
	if [ "${OLD_VALUE}" != "${NEW_VALUE}" ]; then
		/sbin/setcfg ${QPKG_NAME} $1 "${NEW_VALUE}" -f ${PLEXCONNECT_CONF}
		return 1
	fi
	return 0
}

#echo "$1" >> activity.log

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg ${QPKG_NAME} Enable -u -d TRUE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "${QPKG_NAME} is disabled."
        exit 1
    fi

	# Set our variables
	RESTART_APACHE=FALSE
	PLEXCONNECT_GIT="https://github.com/iBaa/PlexConnect.git"
	APACHE_CONF="/usr/local/apache/conf/apache.conf"
	QPKG_CONF="${QPKG_ROOT}/web/settings.cfg"
	PROXY_CONF="${QPKG_ROOT}/apache/proxy.conf"
	PLEXCONNECT_CONF="${QPKG_ROOT}/PlexConnect/Settings.cfg"

	# Create any folders we require
	mkdir -p apache
	mkdir -p certificates

	# Install or update PlexConnect
	if [ ! -d "PlexConnect" ]; then
		git clone -- $PLEXCONNECT_GIT
	else
		cd PlexConnect
		git fetch --all
		git reset --hard origin/master
		cd ..
	fi

	# Workaround for a python / PlexConnect issue that prevents it working on QNAP
	sed -i "s/proxy\.start(initProxy)/proxy.start()/" PlexConnect/PlexConnect.py

	# Check if we have a settings file
	if [ ! -f "${PLEXCONNECT_CONF}" ]; then
		echo "Creating PlexConnect settings file"
		cp -f ${QPKG_CONF} ${PLEXCONNECT_CONF}
		NEW_PLEXCONNECT_CONF=TRUE
	fi

	# Make sure that our local IP is up to date
	LOCAL_IP=`hostname -i | xargs`
	/sbin/setcfg ${QPKG_NAME} ip_pms ${LOCAL_IP} -f ${PLEXCONNECT_CONF}
	/sbin/setcfg ${QPKG_NAME} ip_plexconnect ${LOCAL_IP} -f ${PLEXCONNECT_CONF}

	# Get the host we're intercepting, this can be changed in the config
	NEW_HOSTTOINTERCEPT=`/sbin/getcfg ${QPKG_NAME} hosttointercept -f ${QPKG_CONF}`

	# update the values we want to copy
	#update_conf enable_plexgdm
	update_conf enable_dnsserver
	update_conf prevent_atv_update
	update_conf loglevel
	update_conf hosttointercept
	if [ "$?" == "1" ] || [ "${NEW_PLEXCONNECT_CONF}" == "TRUE" ]; then
		echo "Updating intercepted host"
		/sbin/setcfg ${QPKG_NAME} certfile "../certificates/${NEW_HOSTTOINTERCEPT}.pem" -f "${PLEXCONNECT_CONF}"
		# Make sure our Apache proxy config is hitting the right url and certificate
		sed -e "s/trailers\.key/${NEW_HOSTTOINTERCEPT}.key/" -e "s/trailers\.pem/${NEW_HOSTTOINTERCEPT}.pem/" -e "s/trailers\.apple\.com/${NEW_HOSTTOINTERCEPT}/" -e "s/0\.0\.0\.0/${LOCAL_IP}/" proxy.conf > $PROXY_CONF
		RESTART_APACHE=TRUE
	fi

	# Make sure Apache knows to proxy our connection
	if ! grep -F -q "${QPKG_ROOT}" "${APACHE_CONF}" ; then
		echo "Adding proxy to Apache configuration"
		# Would prefer IncludeOptional, but QNAP doesn't have it
		echo "Include ${QPKG_ROOT}/apache/proxy[.]conf" >> "${APACHE_CONF}"
		RESTART_APACHE=TRUE
	fi

	# Create the certificates if needed
	if [ ! -e "certificates/${NEW_HOSTTOINTERCEPT}.key" ]; then
		echo "Creating certificates"
		openssl req -new -nodes -newkey rsa:2048 -out certificates/${NEW_HOSTTOINTERCEPT}.pem -keyout certificates/${NEW_HOSTTOINTERCEPT}.key -x509 -days 7300 -subj "/C=US/CN=${NEW_HOSTTOINTERCEPT}"
		openssl x509 -in certificates/${NEW_HOSTTOINTERCEPT}.pem -outform der -out certificates/${NEW_HOSTTOINTERCEPT}.cer && cat certificates/${NEW_HOSTTOINTERCEPT}.key >> certificates/${NEW_HOSTTOINTERCEPT}.pem
		RESTART_APACHE=TRUE
	fi

	# Restart Apache if we need to - install or changed host
	if [ "${RESTART_APACHE}" == "TRUE" ]; then
		# Restart Apache
		/etc/init.d/Qthttpd.sh restart
	fi

	# Start PlexConnect
	cd PlexConnect && ./PlexConnect_daemon.bash start
    ;;

  stop)
	# Stop PlexConnect
	cd PlexConnect && ./PlexConnect_daemon.bash stop
    ;;

  restart)
    $0 stop
    $0 start
    ;;

  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac

exit 0
