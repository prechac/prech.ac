require 'pattern'

describe Pattern do
  describe '#initialize' do
    def self.it_should_parse(pattern, expected)
      it "parses #{pattern} as #{expected.inspect}" do
        Pattern.new(pattern).to_a.should == expected
      end
    end

    def self.it_should_parse_as(patterns)
      patterns.each do |pattern, expected|
        it_should_parse pattern, expected
      end
    end

    it_should_parse_as(
      '2.5p3.5p4.5p' => %w[2.5p 3.5p 4.5p],
      '2.5p 3.5p 4.5p' => %w[2.5p 3.5p 4.5p],
      '2.5p,3.5p,4.5p' => %w[2.5p 3.5p 4.5p],
      '2.5p-3.5p-4.5p' => %w[2.5p 3.5p 4.5p],
      '3p3p3p1' => %w[3p 3p 3p 1],
      '3p, 3p - 3p1' => %w[3p 3p 3p 1],
      '3331p' => %w[3 3 3 1p],
      '3/331p' => %w[3 3 3 1p],
    )
  end
end
