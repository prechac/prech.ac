
require 'open-uri'
require 'nokogiri'
require 'redis'

$: << File.expand_path('..', __FILE__) + '/lib'


if ENV['REDISTOGO_URL']
  $redis = Redis.new(url: ENV['REDISTOGO_URL'])
end

# Logging in realtime
$stdout.sync = true

APP_ROOT = Pathname.new(__FILE__).dirname

require 'app'


use Rack::Reloader, 0
use Rack::ContentLength
run App
