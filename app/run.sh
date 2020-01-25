#!/bin/bash

# Adapted from 
# https://github.com/dogweather/phoenix-docker-compose/blob/master/run.sh
set -e


# echo "Testing the installation..."
# # "Prove" that install was successful by running the tests
# mix test

run_server (){
  echo " Launching Phoenix web server..."
  # Start the phoenix web server
  mix phx.server
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

