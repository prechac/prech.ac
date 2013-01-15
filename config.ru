use Rack::Reloader, 0
use Rack::ContentLength

app = proc do |env|
    [ 200, {'Content-Type' => 'text/html'}, ["This will eventually be a url shortener for <a href='http://prechacthis.org'>prechacthis.org</a> once the dns gets set up."] ]
end

run app
