
class Pattern
  attr_reader :pattern
  def initialize(pattern)
    # TODO: Test the crap out of this, it looks like black magic
    @pattern = pattern.split(/\s+|(?<=p)|((?<=\d)(?=\d))/)
  end

  def period
    @pattern.length
  end

  def to_s
    @pattern.join(' ')
  end

  def to_param
    @pattern.join('%20')
  end
end


