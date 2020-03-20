#!/bin/bash
set -e

# Source environment variables
set -a
. ./.env
set +a

function create_letsencrypt_volume {
    docker volume create letsencrypt
}

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
    http-init-certs)
        # Get our TLS certs from LetsEncrypt using the HTTP challenge method
        create_letsencrypt_volume
        docker run --rm \
	    -p 80:80 -it \
	    -v letsencrypt:/etc/letsencrypt \
	    certbot/certbot \
	    certonly \
        --standalone \
	    --preferred-challenges http \
	    -d $DOMAIN
	;;
    dns-init-certs)
        # Get our TLS certs from LetsEncrypt using the DNS challenge method
        create_letsencrypt_volume
        docker run --rm \
            -v /docker/dnsrobocert:/etc/dnsrobocert \
            -v /docker/letsencrypt:/etc/letsencrypt \
            adferrand/dnsrobocert
    ;;
    ls-letsencrypt)
	# List the contents of the letsencrypt volume
        docker run --rm -i -v=letsencrypt:/etc/letsencrypt busybox find /etc/letsencrypt
	;;
    shell)
        # Get a shell in the app container
        docker-compose exec app /bin/bash
        ;;
    dbshell)
        docker-compose exec db psql -U $POSTGRES_USER $POSTGRES_DB
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

