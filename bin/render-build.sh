#!/usr/bin/env bash
# exit on error
set -o errexit

# Ensure bundler is not frozen
bundle config set --local frozen false

# Install dependencies
bundle install

# Asset compilation
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Create SQLite database directory if it doesn't exist
mkdir -p db

# Run migrations
bundle exec rake db:migrate

# Seed the database with initial data
bundle exec rake db:seed 