class Tonal::Comma
  # @return [Hash] of comma key/value pairs
  # @example
  #   Tonal::Comma.commas
  #   => {"diaschisma"=>"2048/2025",
  #       "dicot"=>"25/24",
  #       "dieses1"=>"648/625",
  #       ...}
  #
  def self.commas
    @commas ||= JSON.parse(YAML::load_file("#{__dir__}/../../data/commas.yml", aliases: true).to_json)["commas"]
  end

  # @return [Array] of comma values
  # @example
  #   Tonal::Comma.values
  #   => [(2048/2025), (25/24), (648/625), ...]
  #
  def self.values
    @values ||= commas.values.map(&:to_r)
  end

  # @return [Array] of comma keys
  # @example
  #   Tonal::Comma.keys
  #   => ["diaschisma", "dicot", "dieses1", ...]
  #
  def self.keys
    @keys ||= commas.keys
  end

  # @return [Rational] the comma found in the repo
  # @example
  #   Tonal::Comma.ditonic => (531441/524288)
  #
  def self.method_missing(comma)
    commas[comma.to_s].to_r
  end
end
