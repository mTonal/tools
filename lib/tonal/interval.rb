class Tonal::Interval
  extend Forwardable
  include Comparable

  def_delegators :@interval, :to_r, :antecedent, :consequent

  attr_reader :lower_ratio, :upper_ratio, :interval

  INTERVAL_OF_EQUIVALENCE = 2/1r

  def initialize(upper_ratio, lower_ratio)
    @lower_ratio = lower_ratio.ratio
    @upper_ratio = upper_ratio.ratio
    @interval = @upper_ratio / @lower_ratio
  end
  alias :lower :lower_ratio
  alias :upper :upper_ratio
  alias :numerator :antecedent
  alias :denominator :consequent

  def to_a
    [lower_ratio, upper_ratio]
  end

  def normalize
    ratios = to_a
    lcm = ratios.denominators.lcm
    ratios.map{|r| Tonal::Ratio.new(lcm / r.denominator * r.numerator, lcm)}
  end

  def inspect
    "#{self.to_r} (#{upper.to_r} / #{lower.to_r})"
  end

  def <=>(rhs)
    interval.to_r <=> rhs.interval.to_r
  end
end
