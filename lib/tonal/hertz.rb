class Tonal::Hertz
  include Comparable

  attr_reader :value

  # @return [Tonal::Hertz]
  # @example
  #   Tonal::Hertz.new(1000.0) => 1000.0
  # @param arg [Numeric, Tonal::Hertz]
  #
  def initialize(arg)
    raise ArgumentError, "Argument is not Numeric or Tonal::Hertz" unless arg.kind_of?(Numeric) || arg.kind_of?(self.class)
    @value = arg.kind_of?(self.class) ? arg.inspect : arg
  end

  # @return [Tonal::Hertz] 440 Hz
  # @example
  #   Tonal::Hertz.a440 => 440.0
  #
  def self.a440
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

  # @return [String] the string representation of Tonal::Hertz
  # @example
  #   Tonal::Hertz(1000.0).inspect => "1000.0"
  #
  def inspect
    "#{value}"
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
