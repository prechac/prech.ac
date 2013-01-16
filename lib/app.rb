require 'pattern'
require 'app_cache'

$cache = if ENV['REDIS_URL']
           AppCache.new
         else
           Hash.new
         end

class App

  def self.nothing
    [200, {'Content-Type' => 'text/plain'}, [' ']]
  end

  def self.call(env)
    path = env['PATH_INFO']
    if path == '/favicon.ico'
      nothing
    else
      new(Rack::Utils.unescape(path)).call
    end
  end


  def initialize(path)
    @path = path
    @pattern = Pattern.new(@path.sub(/^\//,''))
  end

  def call
    case @path
    when '/'
      index
    else
      redirect get_url_for_pattern
    end
  end

  def index
    [ 200, {'Content-Type' => 'text/html'}, ["This is a url shortener for <a href='http://prechacthis.org'>prechacthis.org</a>.<br/>Examples: http://prech.ac/2.5p3.5p4.5p http://prech.ac/3p3p3p1 http://prech.ac/332p2.<br/><br/>Made by <a href='http://amielmartin.com'>Amiel Martin</a>"] ]
  end

  def redirect(to)
    [ 302, {'Location' => to, 'Content-Type' => 'text/plain'}, ["Redirecting to #{to}"]]
    # [200, {'Content-Type' => 'text/plain'}, ["Redirecting to #{to}"]]
  end

  def get_url_for_pattern
    if cached?
      $cache[@pattern.to_s]
    else
      search_url = "http://prechacthis.org/index.php?persons=2&objects=&lengths=#{@pattern.period}&max=8&passesmin=1&passesmax=_&jugglerdoes=#{@pattern.to_param}&exclude=&clubdoes=&react=&results=42"

      doc = Nokogiri::HTML(open(search_url))
      swaps = doc.at_css('.swaps a')
      if swaps && swaps.count == 1
        $cache[@pattern.to_s] = fix_url(swaps['href'])
      else
        search_url
      end
    end
  end

  def fix_url(url)
    'http://prechacthis.org/' + url
  end

  def cached?
    $cache[@pattern]
  end

end


