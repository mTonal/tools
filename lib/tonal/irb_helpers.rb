module Tonal
  module IRBHelpers
    # @return [Tonal::Ratio] an unreduced ratio
    # @example
    #   r(3,3) => (3/3)
    # @param arg1 the ratio if only argument provided, or the numerator if two argments are provided
    # @param arg2 the denominator when two arguments are provided
    #
    def r(arg1, arg2=nil)
      Tonal::Ratio.new(arg1, arg2)
    end

    # @return [Tonal::ReducedRatio] a reduced ratio
    # @example
    #   rr(3,3) => (1/1)
    # @param arg1 the ratio if only argument provided, or the numerator if two argments are provided
    # @param arg2 the denominator when two arguments are provided
    #
    def rr(arg1, arg2=nil)
      Tonal::ReducedRatio.new(arg1, arg2)
    end

    # @return [Tonal::Interval] the interval between the given args
    # @example
    #   i(2,3) => (3/2) ((3/2) / (1/1))
    # @example
    #  i(2,3,3,4) => (9/8) ((3/2) / (4/3))
    # @example
    #   i(3) => (3/1) ((3/1) / (1/1))
    # @param args two arguments representing ratios or four arguments representing two pairs of numerator/denominator
    # @param reduced boolean determining whether to use Tonal::ReducedRatio or Tonal::Ratio
    #
    def i(*args, reduced: true)
      Tonal::Interval.new(*args, reduced:)
    end
  end

  # @note
  #   Intended for activation from +~/.irbrc+, by placing: +ENV["MTONAL_IRB_HELPERS" ] = "1"+, in the file
  #
  #   Invoking this command from the IRB will add the helper methods: +r+, +rr+, +i+ in +main+.
  #   These methods represent {Tonal::Ratio}, {Tonal::ReducedRatio} and {Tonal::Interval} respectively.
  #
  # @see Tonal::IRBHelpers
  #
  def self.include_irb_helpers
    Object.include(IRBHelpers)
  end
end