# HelpJuice Search

A real-time search analytics application built with Ruby on Rails and Vanilla JavaScript.

## Overview

HelpJuice Search is a sophisticated search engine that not only provides instant search results but also records and analyzes search patterns. The application focuses on tracking what users are searching for in real-time and provides analytics on search trends.

### Key Features

- **Real-time Search**: Instantly search for articles as you type
- **Smart Query Recording**: Records final search queries, avoiding the "pyramid problem"
- **User-specific Analytics**: Track and display search patterns for individual users
- **Overall Analytics**: View the most popular search terms across all users
- **Article Management**: Browse and view articles in the system

## Technical Details

### Technology Stack

- **Backend**: Ruby on Rails 8.0
- **Frontend**: Vanilla JavaScript, Bootstrap 5
- **Database**: PostgreSQL
- **Testing**: RSpec

### How It Works

1. **Real-time Search**: As users type in the search box, their input is sent to the server in real-time.
2. **Query Recording**: The system records search queries but intelligently identifies when a search is "complete" based on user pauses.
3. **Search Analytics**: The system aggregates and analyzes search patterns, both per-user and globally.
4. **Scalability**: The application is designed to handle thousands of requests per hour with efficient query processing and database indexing.

### Search Algorithm

The search system solves the "pyramid problem" by:
- Recording all search queries in real-time
- Identifying when a search sequence is complete (when the user pauses)
- Only treating the final query in a sequence as a "complete" search
- Filtering out intermediate searches that are just parts of the final query

This approach ensures that analytics show meaningful search patterns rather than counting every keystroke as a separate search.

## Development

### Prerequisites

- Ruby 3.4+
- PostgreSQL
- Node.js & Yarn

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/helpjuice_search.git
cd helpjuice_search

# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start the server
rails server
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific tests
bundle exec rspec spec/models/search_query_spec.rb
```

## Deployment

The application is designed to be deployed on Heroku or any other platform that supports Rails applications.

### Heroku Deployment

```bash
heroku create helpjuice-search
git push heroku main
heroku run rails db:migrate
heroku run rails db:seed
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Built for HelpJuice as a technical assessment
- Uses Bootstrap for UI components
