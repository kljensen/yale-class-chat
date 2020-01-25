#!/bin/bash

# Adapted from 
# https://github.com/dogweather/phoenix-docker-compose/blob/master/run.sh
set -e


# echo "\nTesting the installation..."
# # "Prove" that install was successful by running the tests
# mix test

run_server (){
  echo "\n Launching Phoenix web server..."
  # Start the phoenix web server
  mix phx.server
}

run_migrations(){
  # Wait for Postgres to become available.
  until PGPASSWORD=$POSTGRES_PASSWORD psql -h db -U "$POSTGRES_USER" -c '\q' "$POSTGRES_DB" 2>/dev/null; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1
  done

  echo "\nPostgres is available: continuing with database setup..."

  # Potentially Set up the database
  mix ecto.create
  mix ecto.migrate
}

# Install dependencies
install_dependencies (){
  # Ensure the app's dependencies are installed
  mix deps.get

  # Prepare Dialyzer if the project has Dialyxer set up
  if mix help dialyzer >/dev/null 2>&1
  then
    echo "\nFound Dialyxer: Setting up PLT..."
    mix do deps.compile, dialyzer --plt
  else
    echo "\nNo Dialyxer config: Skipping setup..."
  fi

  # Install JS libraries
  echo "\nInstalling JS..."
  yarn install --cwd assets --link-duplicates --non-interactive
}

run_tests (){
  mix test
}

run_tests_with_watch (){
  mix test.watch
}

setup(){
  install_dependencies
  run_migrations
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
    *)
        echo "Invalid action!"
        exit
        ;;
esac

