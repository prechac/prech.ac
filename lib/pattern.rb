require 'active_support/all'

class Pattern
  NAMES = {
    'holygrail' => %w[2.5p 3.5p 4.5p],
    'babydragon' => %w[4.5p 2.5p 1 1 1],
  }


  attr_reader :pattern
  def initialize(pattern)
    if NAMES['pattern']
      @pattern = NAMES['pattern']
    else
      # TODO: Test the crap out of this, it looks like black magic
      @pattern = pattern.split(/\s+|(?<=p)|((?<=\d)(?=\d))/).select(&:present?)
    end
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


