require 'active_support/all'

class Pattern
  # Easter egg names.
  # TODO: Add more. Pull-requests accepted.
  NAMES = {
    'holygrail' => %w[2.5p 3.5p 4.5p],
    'babydragon' => %w[4.5p 2.5p 1 1 1],
    'babydragontwins' => %w[4.5p 2.5p 4.5p 2.5p 1],
    'thedragon' => %w[4.5p 2.5p 2],
  }

  attr_reader :pattern, :number_of_people
  def initialize(pattern)
    @source = pattern.dup
    if NAMES[pattern]
      @pattern = NAMES[pattern]
    else
      @number_of_people, @pattern = self.class.parse_pattern(pattern.dup)
    end
  end

  def self.parse_pattern(pattern)
    pattern = pattern.gsub(/[^\d\.p:]/, ' ')

    n_people = pattern[/^\d+:/]
    number_of_people = if n_people
      pattern.gsub!(/^\d+:/, '')
      n_people.to_i
    else
      2
    end

    # TODO: Test the crap out of this
    array = pattern.split(/\s+|(?<=p)|((?<=\d)(?=\d))/)
    [number_of_people, array.select(&:present?)]
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

  def to_a
    @pattern
  end

  def inspect
    "#<Pattern #{to_s} source:#{@source}>"
  end
end


