class Tonal::Comma
  def self.commas
    @commas ||= JSON.parse(YAML::load_file("#{__dir__}/../../data/commas.yml", aliases: true).to_json)["commas"]
  end

  def self.values
    @values ||= commas.values.map(&:to_r)
  end

  def self.keys
    @keys ||= commas.keys
  end

  def self.method_missing(comma)
    commas[comma.to_s].to_r
  end
end
