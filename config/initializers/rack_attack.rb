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

RACK_ATTACK_LOGGER = Logger.new('log/rack-attack.log')
ActiveSupport::Notifications.subscribe('rack.attack') do |_, _, _, _, req|
  msg = [req.env['rack.attack.match_type'],
         req.ip,
         req.request_method,
         req.fullpath,
         ('"' + req.device.to_s + '"')].join(' ')

  if [:throttle, :blocklist].include?(req.env['rack.attack.match_type'])
    RACK_ATTACK_LOGGER.error(msg)
  else
    RACK_ATTACK_LOGGER.info(msg)
  end
end
