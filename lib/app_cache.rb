class AppCache
  def initialize(redis)
    @redis = redis
  end

  def [](key)
    @redis.get(cache_key(key))
  end

  def []=(key, value)
    @redis.set(cache_key(key), value) if valid_key?(key)
  end

  def add_recent(path)
    @redis.lrem recents_key, 0, path
    @redis.lpush recents_key, path
    # TODO: Cleanup so there's not too many keys?
  end

  def recents(count)
    @redis.lrange recents_key, 0, count
  end

  private

  def recents_key
    'prechac:recents'
  end

  def valid_key?(key)
    sanitize_key(key).size > 1
  end

  def cache_key(key)
    "prechac:#{sanitize_key(key)}"
  end

  def sanitize_key(key)
    key.gsub(/[^-+\w:\/\. ]/, '')
  end
end
