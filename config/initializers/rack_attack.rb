# frozen_string_literal: true
Rack::Attack.blocklist('fail2ban pentesters') do |req|
  Rack::Attack::Fail2Ban.filter(
    "pentesters-#{req.ip}",
    maxretry: 1,
    findtime: 10.minutes,
    bantime: 1.day
  ) do
    req.path.include?('wp-admin') || req.path.include?('wp-login')
  end
end
