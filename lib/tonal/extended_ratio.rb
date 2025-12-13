module Tonal::ExtendableRatio
  extend Forwardable
  include Comparable
  def_delegators :@partials, :size, :length, :each, :map, :select, :first, :last, :[], :count

  attr_reader :partials

  # @return [Tonal::ExtendedRatio, Tonal::SubharmonicExtendedRatio]
  # @example
  #   Tonal::ExtendedRatio.new(partials: [1, 2, 3])
  #   Tonal::SubharmonicExtendedRatio.new(ratios: [Rational(1,1), Rational(1,2), Rational(1,3)])
  # @param partials [Array<Numeric>] the partials to initialize the extended ratio
  # @param ratios [Array<Rational>] the ratios to initialize the extended ratio
  #
  def initialize(partials: nil, ratios: nil)
    raise(ArgumentError, "Provide either partials or ratios, not both", caller[0]) if !partials.nil? && !ratios.nil?
    raise(ArgumentError, "Provide either partials or ratios", caller[0]) if partials.nil? && ratios.nil?

    if partials
      during_initialize(*partials)
    elsif ratios
      first = ratios.first
      partials = ratios.map{|r| r * first}
      during_initialize(*partials)
    end
  end

  # @return [Tonal::Interval] the interval between two partials
  # @example
  #   er = Tonal::ExtendedRatio.new(partials: [1, 2, 3, 4])
  #   er.interval_between(0, 2) => Tonal::Interval representing 3/2
  #
  def interval_between(index1, index2, reduced: true)
    return nil if self[index1].nil? || self[index2].nil?
    first = partials.first
    r1 = reduced ? Tonal::ReducedRatio.new(self[index1], first) : Tonal::Ratio.new(self[index1], first)
    r2 = reduced ? Tonal::ReducedRatio.new(self[index2], first) : Tonal::Ratio.new(self[index2], first)
    Tonal::Interval.new(r1, r2, reduced:)
  end

  def inspect
    display.join(":")
  end

  private
  def switch_domain(domain)
    case domain
    when :harmonic
      Tonal::ExtendedRatio
    when :subharmonic
      Tonal::SubharmonicExtendedRatio
    else
      raise(ArgumentError, "Unknown domain: #{domain}", caller[0])
    end.new(ratios: ratios.map(&:to_r))
  end
  alias :switch_to :switch_domain
end

class Tonal::ExtendedRatio
  include Tonal::ExtendableRatio

  # @return [Array<Tonal::Ratio, Tonal::ReducedRatio>] the ratios of the extended ratio
  # @example
  #   er = Tonal::ExtendedRatio.new(partials: [4, 5, 6])
  #   er.ratios => [1/1, 5/4, 3/2]
  # @param reduced [Boolean] whether to return reduced ratios or not
  #
  def ratios(reduced: true)
    first = partials.first
    partials.map do |n|
      reduced ? Tonal::ReducedRatio.new(n, first) : Tonal::Ratio.new(n, first)
    end
  end

  # @return [Tonal::SubharmonicExtendedRatio] the subharmonic extended ratio
  # @example
  #   er = Tonal::ExtendedRatio.new(partials: [4, 5, 6])
  #   er.to_subharmonic_extended_ratio => Tonal::SubharmonicExtendedRatio with partials [(1/15), (1/12), (1/10)]
  #
  def to_subharmonic_extended_ratio
    switch_to(:subharmonic)
  end
  alias :to_sefr :to_subharmonic_extended_ratio

  private
  def during_initialize(*args)
    lcm = args.denominators.lcm
    @partials = Array.new(args.map{|n| n * lcm}.numerators).sort
  end

  def display
    @display ||= partials.map{|r| r.round(2)}
  end
end

class Tonal::SubharmonicExtendedRatio
  include Tonal::ExtendableRatio

  # @return [Array<Tonal::Ratio, Tonal::ReducedRatio>] the ratios of the subharmonic extended ratio
  # @example
  #   ser = Tonal::SubharmonicExtendedRatio.new(partials: [6,5,4])
  #   ser.ratios => [1/1, 6/5, 3/2]
  # @param reduced [Boolean] whether to return reduced ratios or not
  #
  def ratios(reduced: true)
    first = partials.first
    partials.map do |n|
      reduced ? Tonal::ReducedRatio.new(n, first) : Tonal::Ratio.new(n, first)
    end
  end

  # @return [Tonal::ExtendedRatio] the harmonic extended ratio
  # @example
  #   ser = Tonal::SubharmonicExtendedRatio.new(partials: [6,5,4])
  #   ser.to_extended_ratio => Tonal::ExtendedRatio with partials [10, 12, 15]
  #
  def to_extended_ratio
    switch_to(:harmonic)
  end
  alias :to_efr :to_extended_ratio

  private
  def during_initialize(*args)
    lcm = args.numerators.lcm
    @partials = args.map{|n| n.kind_of?(Rational) ? n / lcm : n.reciprocal}.sort
  end

  def display
    @display ||= partials.map(&:reciprocal).map{|r| (r % 1).zero? ? r.to_i : r}.map{|r| r.round(2)}
  end
end
