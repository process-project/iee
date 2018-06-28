web: thin start --ssl
jobs: bundle exec sidekiq -q computation -q mailers
clock: bundle exec clockwork lib/clock.rb
