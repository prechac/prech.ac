require 'pattern'
require 'app_cache'
require 'redis'

require 'gabba'

$cache = ($redis ? AppCache.new($redis) : AppCache.new(Redis.new))

MIN_OBJECTS = 1
MAX_OBJECTS_PER_PERSON = 5

class App

  def self.root
    APP_ROOT
  end

  def self.call(env)
    new(env).call
  end

  def self.log(infos)
    puts infos
  end

  def log(infos)
    self.class.log(infos)
  end

  attr_reader :request, :path, :pattern
  def initialize(env)
    @path = Rack::Utils.unescape(env['PATH_INFO'])
    @request = Rack::Request.new env
    @pattern = Pattern.new(@path.sub(/^\//,''))
  end

  def call
    case @path
    when '/'
      index
    when '/robots.txt'
      plaintext("User-Agent: *\nDisallow: /*\nAllow: /$\n")
    when '/favicon.ico'
      plaintext(' ')
    when '/recents.json'
      recents
    else
      track_request!
      redirect get_url_for_pattern
    end
  end

  def plaintext(text)
    [200, {'Content-Type' => 'text/plain'}, [text]]
  end

  def index
    @@index ||= App.root.join('public/index.html').read
    [200, {'Content-Type' => 'text/html'}, [@@index]]
  end

  def recents
    [200, {'Content-Type' => 'application/json'}, [$cache.recents(5).to_json]]
  end

  def redirect(to)
    log "Redirecting to: #{to}"
    [302, {'Location' => to, 'Content-Type' => 'text/plain'}, ["Redirecting to #{to}"]]
    # [200, {'Content-Type' => 'text/plain'}, ["Redirecting to #{to}"]]
  end


  def track_request!
    # No workie :( Need to figure out _ga
    # gabba.identify_user request.cookies['__utma'], request.cookies['__utmz']
    gabba.referer request.env['HTTP_REFERER']
    gabba.ip request.env["REMOTE_ADDR"]
    gabba.page_view("Pattern redirect: #{pattern.cache_key}", path)
  end

  def number_of_people
    @pattern.number_of_people
  end

  def objects_string
    (MIN_OBJECTS..(number_of_people * MAX_OBJECTS_PER_PERSON)).to_a.join('or')
  end

  def get_url_for_pattern
    log "Getting url for pattern:#{@pattern.inspect}"
    if cached?
      log "Cache HIT [#{@pattern}]"
      $cache.add_recent @pattern.source
      $cache[@pattern.cache_key]
    else
      log "Cache MISS [#{@pattern}]"
      search_url = "http://prechacthis.org/index.php?persons=#{@pattern.number_of_people}&objects=#{objects_string}&lengths=#{@pattern.period}&max=8&passesmin=1&passesmax=_&jugglerdoes=#{@pattern.to_param}&exclude=&clubdoes=&react=&results=42"
      log "Searching with #{search_url}"

      doc = Nokogiri::HTML(open(search_url))
      swaps = doc.at_css('.swaps a')
      if swaps && swaps.count == 1
        log "Found 1 result for #{@pattern}"
        $cache.add_recent @pattern.source
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

  def gabba
    @_gabba ||= Gabba::Gabba.new("UA-1309955-17", "prech.ac", request.env['HTTP_USER_AGENT'])
  end

end

