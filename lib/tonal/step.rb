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

  def convert(new_modulo)
    self.class.new(log: log, modulo: new_modulo)
  end

  def to_r
    ratio.to_r
  end

  def to_cents
    ratio.to_cents
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
      if log.kind_of?(Tonal::Log2)
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
