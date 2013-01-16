class AppCache
  def initialize(cache)
    @redis = redis
  end

  def [](key)
    @redis.get(cache_key(key))
  end

  def []=(key, value)
    @redis.set(cache_key(key), value)
  end

  private

  def cache_key(key)
    "prechac:2:#{sanitize_key(key)}"
  end

  def sanitize_key(key)
    key.gsub(/[^-+\w:\/\. ]/, '')
  end
end
