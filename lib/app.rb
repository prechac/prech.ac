require 'pattern'
require 'app_cache'

$cache = ($redis ? AppCache.new($redis) : Hash.new)

class App

  def self.root
    APP_ROOT
  end

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

  def self.log(infos)
    puts infos
  end

  def log(infos)
    self.class.log(infos)
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
    @@index ||= App.root.join('public/index.html').read
    [200, {'Content-Type' => 'text/html'}, [@@index]]
  end

  def redirect(to)
    log "Redirecting to: #{to}"
    [302, {'Location' => to, 'Content-Type' => 'text/plain'}, ["Redirecting to #{to}"]]
    # [200, {'Content-Type' => 'text/plain'}, ["Redirecting to #{to}"]]
  end

  def number_of_people
    @pattern.number_of_people
  end

  def objects_string
    (number_of_people..(number_of_people * 5)).to_a.join('or')
  end

  def get_url_for_pattern
    log "Getting url for pattern:#{@pattern.inspect}"
    if cached?
      log "Cache HIT [#{@pattern}]"
      $cache[@pattern.cache_key]
    else
      log "Cache MISS [#{@pattern}]"
      search_url = "http://prechacthis.org/index.php?persons=#{@pattern.number_of_people}&objects=#{objects_string}&lengths=#{@pattern.period}&max=8&passesmin=1&passesmax=_&jugglerdoes=#{@pattern.to_param}&exclude=&clubdoes=&react=&results=42"
      log "Searching with #{search_url}"

      doc = Nokogiri::HTML(open(search_url))
      swaps = doc.at_css('.swaps a')
      if swaps && swaps.count == 1
        log "Found 1 result for #{@pattern}"
        $cache[@pattern.cache_key] = fix_url(swaps['href'])
      else
        search_url
      end
    end
  end

  def fix_url(url)
    'http://prechacthis.org/' + url
  end

  def cached?
    $cache[@pattern.cache_key]
  end

end

