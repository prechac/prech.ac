
require 'open-uri'
require 'nokogiri'

$: << File.expand_path('..', __FILE__) + '/lib'

require 'app'



use Rack::Reloader, 0
use Rack::ContentLength
run App
