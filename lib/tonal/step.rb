class Tonal::Step
  extend Forwardable
  include Comparable

  def_delegators :@log, :logarithmand

  attr_reader :modulo, :log, :step, :ratio, :tempered

  def initialize(modulo: nil, log: nil, step: nil, ratio: nil)
    raise ArgumentError, "modulo: required" unless modulo
    raise ArgumentError, "One of log:, step: or ratio: must be provided" unless [log, step, ratio].compact.count == 1
    @modulo = modulo.round

    if ratio
      @ratio, @log = derive_ratio_and_log(ratio: ratio)
    elsif step
      @ratio, @log = derive_ratio_and_log(step: step)
    elsif log
      @ratio, @log = derive_ratio_and_log(log: log)
    end

    @step = (modulo * @log).round
    @tempered = 2**(@step.to_f/@modulo)
  end

  def inspect
    "#{step}\\#{modulo}"
  end
  alias :to_s :inspect

  # @return [Tonal::Step] new step with the ratio mapped to the new modulo
  # @example
  #   Tonal::Step.new(ratio: 3/2r, modulo: 31).convert(12)
  #   => 7\12
  #
  def convert(new_modulo)
    self.class.new(log: log, modulo: new_modulo)
  end

  # @return [Rational] of the step
  # @example
  #   Tonal::Step.new(ratio: 3/2r, modulo: 31).step_to_r
  #   => (6735213777669305/4503599627370496)
  #
  def step_to_r
    tempered.to_r
  end
  alias :to_r :step_to_r

  # @return [Rational] of the ratio
  # @example
  #   Tonal::Step.new(ratio: 3/2r, modulo: 31).ratio_to_r
  #   => (3/2)
  #
  def ratio_to_r
    ratio.to_r
  end

  # @return [Tonal::Cents] measure of step in cents
  # @example
  #   Tonal::Step.new(ratio: 3/2r, modulo: 31).step_to_cents
  #   => 696.77
  #
  def step_to_cents
    tempered.to_cents
  end
  alias :to_cents :step_to_cents

  # @return [Tonal::Cents] measure of ratio in cents
  # @example
  #   Tonal::Step.new(ratio: 3/2r, modulo: 31).ratio_to_cents
  #   => 701.96
  #
  def ratio_to_cents
    ratio.to_cents
  end

  # @return [Tonal::Cents] the difference between the step and the ratio
  # @example
  #   Tonal::Step.new(ratio: 3/2r, modulo: 31).efficiency
  #   => 5.19
  #
  def efficiency
    # We want the efficiency from the step (self).
    ratio_to_cents - step_to_cents
  end

  def +(rhs)
    self.class.new(step: (rhs % modulo), modulo: modulo)
  end
  alias :% :+

  def <=>(rhs)
    rhs.kind_of?(self.class) && modulo <=> rhs.modulo && log <=> rhs.log && step <=> rhs.step
  end

  private
  def derive_ratio_and_log(ratio: nil, log: nil, step: nil)
    if ratio
      [Tonal::ReducedRatio.new(ratio), Tonal::Log2.new(logarithmand: ratio)]
    elsif log
      if log.kind_of?(Tonal::Log)
        [log.logarithmand, log]
      else
        lg = Tonal::Log2.new(logarithm: log)
        [Tonal::ReducedRatio.new(lg.logarithmand), lg]
      end
    elsif step
      [Tonal::ReducedRatio.new(2.0**(step.to_f/@modulo)), Tonal::Log2.new(logarithmand: (2.0 ** (step.to_f/@modulo)))]
    end
  end
end
