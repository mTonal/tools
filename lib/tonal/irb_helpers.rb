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
    #   r(3,3) => (1/1)
    # @param arg1 the ratio if only argument provided, or the numerator if two argments are provided
    # @param arg2 the denominator when two arguments are provided
    #
    def rr(arg1, arg2=nil)
      Tonal::ReducedRatio.new(arg1, arg2)
    end

    # @return [Tonal::Interval] the interval between the given args
    # @example
    #   i(2,3) => (3/2) ((3/2) / (1/1))
    # @param args two arguments representing ratios or four arguments representing two pairs of numerator/denominator
    # @param reduced boolean determining whether to use Tonal::ReducedRatio or Tonal::Ratio
    #
    def i(*args, reduced: true)
      Tonal::Interval.new(*args, reduced:)
    end
  end

  # @example
  #   Tonal.include_irb_helpers
  # @note
  #   Invoking will include the IRB helper methods "r", "rr", "i".
  #   These methods represent Tonal::Ratio, Tonal::ReducedRatio and Tonal::Interval respectively
  #   To activate automatically, put the line: ENV["MTONAL_IRB_HELPERS"] = "1" in your ~/.irbrc file
  #
  def self.include_irb_helpers
    Object.include(IRBHelpers)
  end
end