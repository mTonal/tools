class Tonal::Scale
  class Step
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

    # @return [Tonal::Scale::Step] new step with the ratio mapped to the new modulo
    # @example
    #   Tonal::Scale::Step.new(ratio: 3/2r, modulo: 31).convert(12)
    #   => 7\12
    #
    def convert(new_modulo)
      self.class.new(log: log, modulo: new_modulo)
    end

    # @return [Rational] of the step
    # @example
    #   Tonal::Scale::Step.new(ratio: 3/2r, modulo: 31).step_to_r
    #   => (18/31)
    #   Tonal::Scale::Step.new(ratio: 3/2r, modulo: 34).step_to_r
    #   => (10/17)
    #
    def step_to_r
      Rational(step, modulo)
    end

    # @return [Tonal::Ratio] of the step/modulo
    # @example
    #   Tonal::Scale::Step.new(ratio: 3/2r, modulo: 31).step_to_ratio
    #   => 18/31
    #
    def step_to_ratio
      Tonal::Ratio.new(step, modulo)
    end

    # @return [Rational] of the ratio
    # @example
    #   Tonal::Scale::Step.new(ratio: 3/2r, modulo: 31).ratio_to_r
    #   => (3/2)
    #
    def ratio_to_r
      ratio.to_r
    end

    # @return [Tonal::Cents] measure of tempered in cents
    # @example
    #   Tonal::Scale::Step.new(ratio: 3/2r, modulo: 31).tempered_to_cents
    #   => 696.77
    #
    def tempered_to_cents
      tempered.to_cents
    end

    # @return [Tonal::Cents] measure of ratio in cents
    # @example
    #   Tonal::Scale::Step.new(ratio: 3/2r, modulo: 31).ratio_to_cents
    #   => 701.96
    #
    def ratio_to_cents
      ratio.to_cents
    end

    # @return [Tonal::Cents] the difference between the tempered number and the ratio
    # @example
    #   Tonal::Scale::Step.new(ratio: 3/2r, modulo: 31).efficiency => 5.19 ¢
    #
    def efficiency
      # We want the efficiency from the step (self). The tempered value is the tempered approximation of the ratio, so we want to know how far off the step is from the ratio. So we take the ratio and subtract the tempered value.
      ratio_to_cents - tempered_to_cents
    end
    alias :cents_difference :efficiency

    # @return [Boolean] true if the step is coprime to the modulo
    # @example
    #   Tonal::Scale::Step.new(step: 5, modulo: 12).coprime? => true
    #   Tonal::Scale::Step.new(step: 6, modulo: 12).coprime? => false
    #
    def coprime?
      step.coprime?(modulo)
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
end
