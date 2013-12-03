require 'active_support/all'

class Pattern
  # Easter egg names.
  # TODO: Add more. Pull-requests accepted.
  NAMES = {
    'holygrail' => [2, %w[2.5p 3.5p 4.5p]],
    'babydragontwins' => [2, %w[4.5p 2.5p 4.5p 2.5p 1]],
    'thedragon' => [2, %w[4.5p 2.5p 2]],
    'yukishomework' => [3, %w[4p 2p 1 3p 3 1]],

    'sleepingdragon' => [2, %[3.5p 2.5p 1 1 1]],
    'babydragon' => [2, %w[4.5p 2.5p 1 1 1]],

    # TODO: Pick a good name for this pattern.
    'awesometriangle' => [3, %w[3p 4p 3 3 4p 3]],
  }

  attr_reader :pattern, :number_of_people, :source
  def initialize(pattern)
    @source = pattern.dup
    if NAMES[pattern]
      @number_of_people, @pattern = NAMES[pattern]
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

  def cache_key
    [number_of_people, to_s].join(':')
  end

  def to_param
    @pattern.join('%20')
  end

  def to_a
    @pattern
  end

  def inspect
    "#<Pattern #{to_s} people:#{@number_of_people} source:#{@source}>"
  end
end


