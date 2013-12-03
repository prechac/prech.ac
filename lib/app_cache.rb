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

  private

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
