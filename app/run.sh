#!/bin/bash

# Adapted from 
# https://github.com/dogweather/phoenix-docker-compose/blob/master/run.sh
set -e


# echo "Testing the installation..."
# # "Prove" that install was successful by running the tests
# mix test

run_server (){
  # Start the phoenix web server
  # Infinitely start and wait. This allows us to kill
  # the Erlang process without having this shell script
  # exit.
  while true
  do
    echo "Launching Phoenix web server..."
    mix phx.server &
    wait
    echo "...server exited, restarting..."
  done
}

run_migrations(){
  # Wait for Postgres to become available.
  until PGPASSWORD=$POSTGRES_PASSWORD psql -h db -U "$POSTGRES_USER" -c '\q' "$POSTGRES_DB" 2>/dev/null; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1
  done

  echo "Postgres is available: continuing with database setup..."

  # Potentially Set up the database
  mix ecto.create
  mix ecto.migrate
}

setup_dialyzer (){
  # Prepare Dialyzer if the project has Dialyxer set up
  if mix help dialyzer >/dev/null 2>&1
  then
    echo "Found Dialyxer: Setting up PLT..."
    mix do deps.compile, dialyzer --plt
  else
    echo "No Dialyxer config: Skipping setup..."
  fi
}

# Install dependencies
install_dependencies (){
  # Ensure the app's dependencies are installed
  mix deps.get

  # Install JS libraries
  echo "Installing JS..."
  yarn install --cwd assets --link-duplicates --non-interactive
}

run_tests (){
  mix test
}

run_tests_with_watch (){
  # Infinitely start and wait. This allows us to kill
  # the Erlang process without having this shell script
  # exit.
  while true
  do
    echo "Watching tests..."
    mix test.watch &
    wait
  done
}

setup(){
  install_dependencies
  run_migrations
}

sighup_beam(){
  # Sends SIGHUP to all beam processes
  # in the container. Useful for restarting
  # the server without running `setup`.
  pkill -f beam --signal HUP
}

ACTION=$1
case $ACTION in
    server)
        setup
        run_server
        ;;
    tests)
        setup
        run_tests
        ;;
    watch-tests)
        setup
        run_tests_with_watch
        ;;
    sighup-beam)
        sighup_beam
        ;;
    *)
        echo "Invalid action!"
        exit
        ;;
esac

