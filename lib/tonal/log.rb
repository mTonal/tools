class Tonal::Log
  extend Forwardable
  include Comparable

  def_delegators :@logarithmand, :ratio, :to_ratio

  attr_reader :logarithmand, :logarithm, :base

  # @return [Tonal::Log]
  # @example
  #   Tonal::Log.new(logarithmand: 3/2r, base: 2) => 0.5849625007211562
  # @param logarithmand
  # @param logarithm
  # @param base
  #
  def initialize(logarithmand: nil, logarithm: nil, base: nil)
    raise ArgumentError, "logarithmand or logarithm must be provided" if logarithmand.nil? && logarithm.nil?
    raise ArgumentError, "logarithmand must be Numeric" unless logarithmand.kind_of?(Numeric) || logarithmand.nil?
    raise ArgumentError, "logarithm must be Numeric" unless logarithm.kind_of?(Numeric) || logarithm.nil?

    if logarithmand && logarithm && base
      @logarithmand = logarithmand
      @logarithm = logarithm
      @base = derive_base(logarithmand: logarithmand, logarithm: logarithm)
      puts "Provided base (#{base}) does not align with logarithmand and logarithm. Using calculated base (#{@base}) instead" if @base != base
    elsif logarithmand && logarithm
      @logarithmand = logarithmand
      @logarithm = logarithm
      @base = derive_base(logarithmand: logarithmand, logarithm: logarithm)
    elsif logarithmand && base
      @logarithmand = logarithmand
      @base = base
      @logarithm = derive_logarithm(logarithmand: logarithmand, base: @base)
    elsif logarithm && base
      @base = base
      @logarithm = logarithm
      @logarithmand = derive_logarithmand(logarithm: logarithm, base: @base)
    elsif logarithmand
      @logarithmand = logarithmand
      @base = self.class.base
      @logarithm = derive_logarithm(logarithmand: logarithmand, base: @base)
    elsif logarithm
      @base = self.class.base
      @logarithm = logarithm
      @logarithmand = derive_logarithmand(logarithm: logarithm, base: @base)
    end
  end

  def self.base
    Math::E
  end

  # @return [Tonal::Cents] the cents scale logarithm
  # @example
  #   Tonal::Log.new(logarithmand: 3/2r, base: 2).to_cents => 701.96
  # @see Tonal::Cents
  #
  def to_cents(precision: Tonal::Cents::PRECISION)
    Tonal::Cents.new(log: self, precision: precision)
  end

  # @return [Tonal::Step] the nearest step in the given modulo
  # @example
  #   Tonal::Log.new(logarithmand: 3/2r, base: 2).step(12) => 7\12
  #
  def step(modulo)
    Tonal::Step.new(modulo: modulo, log: self)
  end

  # @return [String] the string representation of Tonal::Log
  # @example
  #   Tonal::Log.new(logarithmand: 3/2r, base: 2).inspect => "0.58"
  #
  def inspect
    "#{logarithm.round(2)}"
  end

  def <=>(rhs)
    rhs.kind_of?(self.class) ? logarithm <=> rhs.logarithm : logarithm <=> rhs
  end

  private
  def derive_base(logarithmand:, logarithm:)
    logarithmand**(1.0/logarithm)
  end

  def derive_logarithmand(logarithm:, base:)
    base**logarithm
  end

  def derive_logarithm(logarithmand:, base:)
    case logarithmand
    when Tonal::Cents
      logarithmand.value / Tonal::Cents::CENT_SCALE
    when Tonal::Ratio
      Math.log(logarithmand.antecedent.to_f / logarithmand.consequent) / Math.log(base)
    else
      Math.log(logarithmand) / Math.log(base)
    end
  end

  def method_missing(op, *args, &blk)
    rhs = args.collect do |arg|
      arg.kind_of?(self.class) ? arg.inspect : arg
    end
    result = logarithm.send(op, *rhs)
    return result if op == :coerce
    case result
    when Numeric
      self.class.new(result)
    else
      result
    end
  end
end

