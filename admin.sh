#!/bin/bash
set -e

# Source environment variables
set -a
. ./.env
set +a

ACTION=$1
case $ACTION in
    up)
        # Bring up all our processes in development
        docker-compose up
        ;;
    down)
        # Bring down all our processes in development
        docker-compose down
        ;;
    prod-up)
        # Bring up all our processes in production
        docker-compose -f docker-compose.prod.yaml up
        ;;
    prod-down)
        # Bring up all our processes in production
        docker-compose -f docker-compose.prod.yaml down
        ;;
    prod-init-certs)
	# Get our TLS certs from LetsEncrypt
        docker volume create letsencrypt
        docker run \
	    -p 80:80 -it \
	    -v letsencrypt:/etc/letsencrypt \
	    certbot/certbot \
	    certonly \
            --standalone \
	    --preferred-challenges http \
	    -d $DOMAIN
	;;
    ls-letsencrypt)
	# List the contents of the letsencrypt volume
        docker run --rm -i -v=letsencrypt:/etc/letsencrypt busybox find /etc/letsencrypt
	;;
    shell)
        # Get a shell in the app container
        docker-compose exec app /bin/bash
        ;;
    iex)
        # Get an iex shell in the app container
        docker-compose exec app /app/run.sh iex
        ;;
    restart)
        # Restart all elixir/erlang/beam processes
        # TODO: NOT WORKING RIGHT NOW. 
        docker-compose exec app /app/run.sh sighup-beam
        docker-compose exec tests /app/run.sh sighup-beam
        ;;
    reup)
        # Bring down all processes in development, then bring back up
        docker-compose down
        docker-compose up
        ;;
    *)
        echo "Invalid action!"
        exit
        ;;
esac

