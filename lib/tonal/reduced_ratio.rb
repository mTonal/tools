class Tonal::ReducedRatio < Tonal::Ratio
  IDENTITY_RATIO = 1/1r

  # @return [Tonal::ReducedRatio]
  # @example
  #   Tonal::ReducedRatio.new(12,2) => (3/2)
  # @param antecedent [Numeric, Tonal::Ratio]
  # @param consequent [Numeric, Tonal::Ratio]
  # @param equave the interval of equivalence, default 2/1
  #
  def initialize(antecedent, consequent=1, label: nil, equave: 2/1r)
    super(antecedent, consequent, label: label, equave: equave)
    @antecedent, @consequent = @reduced_antecedent, @reduced_consequent
  end

  def self.identity
    self.new(IDENTITY_RATIO)
  end

  # @return [Tonal::Ratio] self as an instance of unreduced ratio
  # @example
  #   Tonal::ReducedRatio.new(3,2).to_basic_ratio => (3/2)
  #
  def to_basic_ratio
    Tonal::Ratio.new(antecedent, consequent)
  end

  # @return [Tonal::Interval] between ratio (upper) and self (lower)
  # @example
  #   Tonal::ReducedRatio.new(133).interval_with(3/2r)
  #   => 192/133 (3/2 / 133/128)
  # @param ratio
  #
  def interval_with(ratio)
    r = ratio.is_a?(self.class) ? ratio : self.class.new(ratio)
    Tonal::Interval.new(r, self)
  end

  # @return [Tonal::ReducedRatio] with antecedent and precedent switched
  # @example
  #   Tonal::ReducedRatio.new(3,2).invert! => (4/3)
  #
  def invert!
    super
    @antecedent, @consequent = @reduced_antecedent, @reduced_consequent
    self
  end
end
