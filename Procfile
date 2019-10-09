web: bundle exec puma -C ./config/puma.rb
# web: bundle exec thin start --ssl
jobs: bundle exec sidekiq -q computation -q mailers
clock: bundle exec clockwork lib/clock.rb
