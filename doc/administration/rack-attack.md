# Rack attack

[Rack attack gem](https://github.com/kickstarter/rack-attack) is configured to
protect vapor portal from ddos. Configuration can be found in
[`config/initializers/rack_attack.rb`](../../config/initializers/rack_attack.rb)

## Removing ip from fail2ban

If you want to remove concrete IP from fail2ban list use redis client:

```
# database number can be found in redis configuration e.g.
# redis://localhost:6379/2
redis-cli -n 2

127.0.0.1:6379[2]> keys *rack::attack*
1) "cache:vapor:rack::attack:fail2ban:ban:pentesters-127.0.0.1"
127.0.0.1:6379[2]> del cache:vapor:rack::attack:fail2ban:ban:pentesters-127.0.0.1
```
