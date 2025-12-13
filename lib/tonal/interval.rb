class Tonal::Interval
  extend Forwardable
  include Comparable

  def_delegators :@interval, :to_r, :antecedent, :consequent, :to_cents

  attr_reader :lower_ratio, :upper_ratio, :interval

  INTERVAL_OF_EQUIVALENCE = 2/1r

  # @return [Tonal::Interval] the interval of the given ratios
  # @example
  #   Tonal::Interval.new(2,3) => (3/2) ((3/2) / (1/1))
  # @example
  #   Tonal::Interval.new(2,3,3,4) => (9/8) ((3/2) / (4/3))
  # @example
  #   Tonal::Interval.new(3) => (3/1) ((3/1) / (1/1))
  # @param args two arguments representing ratios or four arguments representing two pairs of numerator/denominator
  # @param reduced boolean determining whether to use Tonal::ReducedRatio or Tonal::Ratio
  #
  def initialize(*args, reduced: true)
    args = [1/1r, args[0]] if args.length == 1
    klass = reduced ? Tonal::ReducedRatio : Tonal::Ratio
    raise(ArgumentError, "Two or four arguments required. Either two ratios, or two pairs of numerator, denominator", caller[0]) unless [2, 4].include?(args.size)
    @lower_ratio, @upper_ratio = case args.size
                                 when 2
                                   [klass.new(args[0].antecedent, args[0].consequent), klass.new(args[1].antecedent, args[1].consequent)]
                                 when 4
                                   [klass.new(args[0],args[1]), klass.new(args[2], args[3])]
                                 end
    @interval = @upper_ratio / @lower_ratio
  end
  alias :ratio :interval
  alias :lower :lower_ratio
  alias :upper :upper_ratio
  alias :numerator :antecedent
  alias :denominator :consequent

  def to_a
    [lower_ratio, upper_ratio]
  end

  def denominize
    ratios = to_a
    lcm = ratios.denominators.lcm
    ratios.map{|r| Tonal::Ratio.new(lcm / r.denominator * r.numerator, lcm)}
  end

  def inspect
    "#{interval.label} (#{upper.label} / #{lower.label})"
  end

  def <=>(rhs)
    interval.to_r <=> rhs.interval.to_r
  end
end

module Interval
  def self.[](l, u, reduced=true)
    Tonal::Interval.new(l, u, reduced:)
  end
end
