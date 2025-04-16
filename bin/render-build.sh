#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Create SQLite database directory if it doesn't exist
mkdir -p db

# Run migrations
bundle exec rake db:migrate 