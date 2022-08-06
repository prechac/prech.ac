require 'open-uri'
require 'nokogiri'
require 'redis'
require 'pathname'

$: << File.expand_path(__dir__) + '/lib'

$redis = Redis.new(url: ENV['REDIS_URL']) if ENV['REDIS_URL']

# Logging in realtime
$stdout.sync = true

APP_ROOT = Pathname.new(__FILE__).dirname

require 'app'

use Rack::Reloader, 0
use Rack::ContentLength
run App
