#!/bin/sh

CERTBOT_OPTIONS=""
case "$CHALLENGE_METHOD" in
    [Hh][Tt][Tt][Pp] )
        echo "Using HTTP challenge validation method"
        CERTBOT_OPTIONS="--webroot --webroot-path /tmp/webroot/ --standalone --preferred-challenges http"
        ;;
    [Dd][Nn][Ss] )
        echo "Using DNS challenge validation method"
        CERTBOT_OPTIONS="--dns-route53 --dns-route53-propagation-seconds 30"
        ;;
     *)
        echo "NOT using HTTP challenge validation method. Quitting."
        exit
        ;;
esac


COMMAND="certbot certonly $CERTBOT_OPTIONS -d $DOMAIN $EXTRA_OPTIONS"
if [ -n "$ONCE" ] ; then
    echo $COMMAND
    $COMMAND
    exit
fi

while true 
do 
    echo "Sleeping 2m..."
    sleep 2m
    if [ "$MIX_ENV" = "prod" ]; then
        echo $COMMAND
        $COMMAND
    else 
        echo "In development mode, not using certbot"
    fi
done
