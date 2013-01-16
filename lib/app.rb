require 'pattern'

class App
  @@cache = {}

  def self.nothing
    [200, {'Content-Type' => 'text/plain'}, [' ']]
  end


  def self.call(env)
    path = env['PATH_INFO']
    if path == '/favicon.ico'
      nothing
    else
      new(path).call
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
    [ 200, {'Content-Type' => 'text/html'}, ["This will eventually be a url shortener for <a href='http://prechacthis.org'>prechacthis.org</a> once the dns gets set up."] ]
  end

  def redirect(to)
    # [ 301, {'Location' => to, 'Content-Type' => 'text/plain'}, ["Redirecting to #{to}"]]
    [200, {'Content-Type' => 'text/plain'}, ["Redirecting to #{to}"]]
  end

  def get_url_for_pattern
    if cached?
      @@cache[@pattern.to_s]
    else
      search_url = "http://prechacthis.org/index.php?persons=2&objects=&lengths=#{@pattern.period}&max=8&passesmin=1&passesmax=_&jugglerdoes=#{@pattern.to_param}&exclude=&clubdoes=&react=&results=42"

      doc = Nokogiri::HTML(open(search_url))
      swaps = doc.at_css('.swaps a')
      if swaps && swaps.count == 1
        @@cache[@pattern.to_s] = fix_url(swaps['href'])
      else
        search_url
      end
    end
  end

  def fix_url(url)
    'http://prechacthis.org/' + url
  end

  def cached?
    @@cache[@pattern]
  end

end


