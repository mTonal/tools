class Tonal::Hertz
  include Comparable

  attr_reader :value

  # @return [Tonal::Hertz]
  # @example
  #   Tonal::Hertz.new(1000.0) => 1000.0 Hz
  # @param arg [Numeric, Tonal::Hertz]
  #
  def initialize(arg)
    raise ArgumentError, "Argument is not Numeric or Tonal::Hertz" unless arg.kind_of?(Numeric) || arg.kind_of?(self.class)
    @value = arg.kind_of?(self.class) ? arg.inspect : arg
  end

  # @return [Tonal::Hertz] 440 Hz
  # @example
  #   Tonal::Hertz.reference => 440.0 Hz
  #
  def self.reference
    self.new(440.0)
  end

  # @return [Rational] self as a rational
  # @example
  #   Tonal::Hertz.new(440).to_r => (440/1)
  #
  def to_r
    Rational(value)
  end

  # @return [Rational] self as a float
  # @example
  #   Tonal::Hertz.new(440).to_f => 440.0
  #
  def to_f
    value.to_f
  end

  # @return [Tonal::Cents] the cents difference between self and a reference frequency
  # @example
  #   Tonal::Hertz.new(880).to_cents => 1200.0
  # @param reference [Tonal::Hertz, Numeric] the reference frequency to compare to
  #
  def to_cents(reference: self.class.reference)
    Tonal::Cents.new(ratio: to_r / reference.to_r)
  end

  # @return [String] the string representation of Tonal::Hertz
  # @example
  #   Tonal::Hertz(1000.0).inspect => "1000.0 Hz"
  #
  def inspect
    "#{value} Hz"
  end

  def <=>(rhs)
    rhs.kind_of?(self.class) ? value <=> rhs.value : value <=> rhs
  end

  def method_missing(op, *args, &blk)
    rhs = args.collect do |arg|
      arg.kind_of?(self.class) ? arg.value : arg
    end
    result = value.send(op, *rhs)
    return result if op == :coerce
    result.kind_of?(Numeric) ? self.class.new(result) : result
  end
end
