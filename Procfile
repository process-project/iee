web: thin start --ssl
# web: bundle exec puma -C ./config/puma.rb
jobs: bundle exec sidekiq -q computation -q mailers
clock: bundle exec clockwork lib/clock.rb
