class Tonal::Cents
  extend Forwardable
  include Comparable

  def_delegators :@log, :logarithm, :logarithmand, :base

  HUNDREDTHS_ROUNDOFF = -2
  FLOAT_PRECISION = 100
  CENT_SCALE = 1200.0
  TOLERANCE = 5
  PRECISION = 2

  attr_reader :log, :ratio

  # @return [Tonal::Cents]
  # @example
  #   Tonal::Cents.new(ratio: 2**(2.0/12)) => 200.0
  # @param cents [Numeric, Tonal::Log2]
  # @param log [Numeric, Tonal::Log2]
  # @param ratio [Numeric, Tonal::Log2]
  # @param precision [Numeric]
  #
  def initialize(cents: nil, log: nil, ratio: nil, precision: PRECISION)
    raise ArgumentError, "One of cents:, log: or ratio: must be provided" unless [cents, log, ratio].compact.count == 1

    @precision = precision

    if cents
      @log = derive_log(cents: cents)
      @value = derive_cents(cents: cents)
      @ratio = derive_ratio(log: @log)
    elsif log
      @log = derive_log(log: log)
      @value = derive_cents(log: @log)
      @ratio = derive_ratio(log: @log)
    elsif ratio
      @log = derive_log(ratio: ratio)
      @value = derive_cents(log: @log)
      @ratio = derive_ratio(ratio: ratio)
    end
  end

  # @return [Tonal::Cents] the default cents tolerance
  # @example
  #   Tonal::Cents.default_tolerance => 5
  #
  def self.default_tolerance
    self.new(cents: TOLERANCE)
  end

  # @return [Float] value of self
  # @example
  #   Tonal::Cents.new(ratio: 2**(1.0/12)).value => 100.00
  #
  def value(precision: @precision)
    @value.round(precision)
  end
  alias :cents :value
  alias :to_f :value

  # @return
  #   [Tonal::Cents] nearest hundredth cent value
  # @example
  #   Tonal::Cents.new(cents: 701.9550008653874).nearest_hundredth => 700.0
  #
  def nearest_hundredth
    self.class.new(cents: value.round(Tonal::Cents::HUNDREDTHS_ROUNDOFF).to_f)
  end

  # @return
  #   [Tonal::Cents] nearest hundredth cent difference
  # @example
  #   Tonal::Cents.new(cents: 701.9550008653874).nearest_hundredth_difference => 1.96
  #
  def nearest_hundredth_difference
    self.class.new(cents: (value - nearest_hundredth))
  end

  # @return [Array] a tuple of self offset positively/negatively by limit
  # @example
  #   Tonal::Cents.new(cents: 100.0).plus_minus
  #   => [95.0, 105.0]
  #
  def plus_minus(limit = 5)
    [self - limit, self + limit]
  end

  # @return
  #   [String] the string representation of Tonal::Cents
  # @example
  #   Tonal::Cents.new(100.0).inspect => "100.0"
  #
  def inspect
    "#{value.round(@precision)}"
  end
  alias :to_s :inspect

  # Operator overloads
  #
  # @return [Tonal::Cents, Numeric] result of operation
  # @example
  #   Tonal::Cents.new(cents: 200) - Tonal::Cents.new(cents: 100) => 100.0
  # @param rhs [Tonal::Cents, Numeric]
  #
  def -(rhs)
    method_missing(:-, rhs)
  end

  # @return [Tonal::Cents, Numeric] result of operation
  # @example
  #   Tonal::Cents.new(cents: 100) + Tonal::Cents.new(cents: 200) => 300.0
  # @param rhs [Tonal::Cents, Numeric]
  #
  def +(rhs)
    method_missing(:+, rhs)
  end

  # @return [Tonal::Cents, Numeric] result of operation
  # @example
  #  Tonal::Cents.new(cents: 200) * 2 => 400.0
  # @param rhs [Tonal::Cents, Numeric]
  #
  def *(rhs)
    method_missing(:*, rhs)
  end

  # @return [Tonal::Cents, Numeric] result of operation
  # @example
  #   Tonal::Cents.new(cents: 400) / 2 => 200.0
  # @param rhs [Tonal::Cents, Numeric]
  #
  def /(rhs)
    method_missing(:/, rhs)
  end

  # Challenges to comparing floats
  # https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Lint/FloatComparison
  # https://embeddeduse.com/2019/08/26/qt-compare-two-floats/
  #
  def <=>(rhs)
    rhs.kind_of?(self.class) ? value.round(PRECISION) <=> rhs.value.round(PRECISION) : value.round(PRECISION) <=> rhs.round(PRECISION)
  end

  private
  def derive_log(cents: nil, ratio: nil, log: nil)
    return Tonal::Log2.new(logarithm: cents / CENT_SCALE) if cents
    return Tonal::Log2.new(logarithmand: ratio) if ratio
    log.kind_of?(Tonal::Log) ? log : Tonal::Log2.new(logarithm: log)
  end

  def derive_ratio(log: nil, ratio: nil)
    return Tonal::ReducedRatio.new(log.logarithmand) if log
    Tonal::ReducedRatio.new(ratio.numerator, ratio.denominator)
  end

  def derive_cents(cents: nil, log: nil)
    return cents if cents
    log.logarithm * CENT_SCALE if log
  end

  # All these operators are binary except for |, ~ and typeof , so the left
  # hand (A) object would be the context object, and the right hand object (B)
  # would be the argument passed to the operator member in A. For unary
  # operators, there won't be arguments, and the function would be called upon
  # its target. operator functions would only be called if the operator is
  # explicitly used in the source code.
  #
  def method_missing(op, *args, &blk)
    rhs = args.collect do |arg|
      arg.kind_of?(self.class) ? arg.value : arg
    end
    result = value.send(op, *rhs)
    return result if op == :coerce
    case result
    when Numeric
      self.class.new(cents: result)
    else
      result
    end
  end
end
