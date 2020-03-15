#!/bin/sh
trap exit TERM;
while true 
do 
	if [ "$MIX_ENV" = "prod" ]; then
		certbot renew
	else 
		echo "In development mode, not using certbot"
	fi
	sleep 12h
done
