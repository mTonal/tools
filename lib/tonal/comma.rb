class Tonal::Comma
  # @return [Hash] of comma key/value pairs
  # @example
  #   Tonal::Comma.commas
  #   => {"ditonic"=>"531441/524288",
  #       "syntonic"=>"81/80",
  #       "schisma"=>"32805/32768",
  #       ...}
  #
  def self.commas
    @commas ||= JSON.parse(YAML::load_file("#{__dir__}/../../data/commas.yml", aliases: true).to_json)["commas"]
  end

  # @return [Array] of comma values
  # @example
  #   Tonal::Comma.values
  #   => [(531441/524288),
  #       (81/80),
  #       (32805/32768),
  #       ...]
  #
  def self.values
    @values ||= commas.values.map(&:to_r)
  end

  # @return [Array] of comma keys
  # @example
  #   Tonal::Comma.keys
  #   => ["ditonic",
  #       "syntonic",
  #       "schisma",
  #       ...]
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
