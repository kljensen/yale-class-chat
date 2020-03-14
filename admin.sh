#!/bin/bash
set -e

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

