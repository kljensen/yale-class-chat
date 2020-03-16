#!/bin/sh
trap exit TERM;
echo "Certbot script started"
while true 
do 
	sleep 2m
	if [ "$MIX_ENV" = "prod" ]; then
		certbot renew --webroot --webroot-path /tmp/webroot/
	else 
		echo "In development mode, not using certbot"
	fi
done
