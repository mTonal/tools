class Tonal::Ratio
  extend Forwardable
  include Comparable

  def_delegators :@approximation, :neighborhood

  PRECISION = 2

  attr_reader :antecedent, :consequent, :equave, :reduced_antecedent, :reduced_consequent

  attr_accessor :label

  # @return [Tonal::Ratio]
  # @example
  #   Tonal::Ratio.new(3,2) => (3/2)
  # @param antecedent [Numeric, Tonal::Ratio]
  # @param consequent [Numeric, Tonal::Ratio]
  #
  def initialize(antecedent, consequent=nil, label: nil, equave: 2/1r)
    raise ArgumentError, "Antecedent must be Numeric" unless antecedent.kind_of?(Numeric)
    raise ArgumentError, "Consequent must be Numeric or nil" unless (consequent.kind_of?(Numeric) || consequent.nil?)

    _initialize(antecedent, consequent, label:, equave:)
  end

  alias :numerator :antecedent
  alias :denominator :consequent

  # @return [Tonal::Ratio] ratio who's numerator and denominator are seperated by a difference of 1
  # @example
  #   Tonal::Ratio.superparticular(100) = (101/100)
  # @param n [Integer] number from which the superior part is calculated
  # @param factor [Rational] multiplied into the resulting ratio, default 1/1
  # @param superpart [Symbol] assigning the superior part to the antecedent or consequent
  #
  def self.superparticular(n, factor: 1/1r, superpart: :upper)
    superpartient(n, summand: 1, factor:, superpart:)
  end

  # @return [Tonal::Ratio] ratio who's numerator and denominator are separated by a summand difference
  # @example
  #   Tonal::Ratio.superpartient(23, summand: 3) => (26/23)
  # @param n [Integer] number from which the superior part is calculated
  # @param summand [Integer] term added to the superior part
  # @param factor [Rational] multiplied into the resulting ratio, default 1/1
  # @param superpart [Symbol] assigning the superior part to the antecedent or consequent
  #
  def self.superpartient(n, summand:, factor: 1/1r, superpart: :upper)
    case superpart.to_sym.downcase
    when :lower, :consequent, :denominator
      self.new(n*factor.numerator, (n+summand)*factor.denominator)
    else
      self.new((n+summand)*factor.numerator, n*factor.denominator)
    end
  end

  # @return [Tonal::Ratio] a randomly generated ratio
  # @example
  #   Tonal::Ratio.random_ratio => (169/1)
  # @param number_of_factors
  # @param within
  #
  def self.random_ratio(number_of_factors = 2, within: 100, reduced: false)
    primes = Prime.each(within).to_a
    nums = []
    dens = []
    1.upto(number_of_factors) do
      nums << [primes[rand(10)], rand(3)]
      dens << [primes[rand(10)], rand(3)]
    end
    [nums, dens].ratio_from_prime_divisions(reduced:)
  end

  # @return [Tonal::Ratio] the ratio of step in the modulo
  # @example
  #   Tonal::Ratio.ed(12, 7)
  #     => (4771397596969315/4503599627370496)
  # @param modulo
  # @param step
  # @param equave
  #
  def self.ed(modulo, step, equave: 2/1r)
    self.new(2**(step.to_f/modulo), equave: equave)
  end

  # @return [Boolean] if pair of ratios are within the given cents limit
  # @example
  #   Tonal::Ratio.within_cents?(100, 105, 2) => false
  # @param cents1
  # @param cents2
  # @param within
  #
  def self.within_cents?(cents1, cents2, within)
    (cents1 - cents2).abs <= within
  end

  # @return [Tonal::Ratio] convenience method returning self
  #
  def ratio
    self
  end
  alias :to_ratio :ratio

  # @return [Tonal::Ratio::Approximation] self's approximation instance
  #
  def approximate
    @approximation
  end

  # ==================================
  # Conversions
  # ==================================

  # @return [Array] antecedent and consequent as elements of Array
  # @example
  #   Tonal::Ratio.new(3,2).to_a => [3, 2]
  #
  def to_a
    [antecedent, consequent]
  end

  # @return [Vector] antecedent and consequent as elements of Vector
  # @example
  #   Tonal::Ratio.new(3,2).to_v => Vector[3, 2]
  #
  def to_v
    Vector[antecedent, consequent]
  end

  # @return [Rational] self as a Rational
  # @example
  #   Tonal::Ratio.new(3,2).to_r => (3/2)
  #
  def to_r
    return Float::INFINITY if consequent.zero? || !antecedent.finite?
    Rational(antecedent, consequent)
  end

  # @return [Float] self as a Float
  # @example
  #   Tonal::Ratio.new(3,2).to_f => 1.5
  #
  def to_f
    antecedent.to_f / consequent.to_f
  end

  # @return [Tonal::Log] Math.log of self in given base
  # @example
  #   Tonal::Ratio.new(3,2).log(3) => 0.37
  # @param base
  #
  def to_log(base=2)
    Tonal::Log.new(logarithmand: to_r, base: base)
  end
  alias :log :to_log

  # @return [Tonal::Log2] Math.log2 of self
  # @example
  #   Tonal::ReducedRatio.new(3,2).to_log2 => 0.58
  #
  def to_log2
    Tonal::Log2.new(logarithmand: to_r)
  end
  alias :log2 :to_log2

  # @return [Tonal::Cents] cents value of self
  # @example
  #   Tonal::Ratio.new(3,2).to_cents => 701.96
  #
  def to_cents
    Tonal::Cents.new(ratio: to_r)
  end
  alias :cents :to_cents

  # @return [Integer] the step of self in the given modulo
  # @example
  #   Tonal::ReducedRatio.new(3,2).step(12) => 7\12
  #
  def step(modulo=12)
    Tonal::Step.new(ratio: to_r, modulo: modulo)
  end

  # @return [Float] degrees
  # @example
  #   Tonal::Ratio.new(3,2).period_degrees => 210.59
  # @param round
  #
  def period_degrees(round: PRECISION)
    (360.0 * Math.log(to_f, equave)).round(round)
  end

  # @return [Float] radians
  # @example
  #   Tonal::Ratio.new(3,2).period_radians => 3.68
  # @param round
  #
  def period_radians(round: PRECISION)
    (2 * Math::PI * Math.log(to_f, equave)).round(round)
  end

  # @return [Tonal::Ratio] copy of self rationally reduced
  # @example
  #   Tonal::Ratio.new(16,14).fraction_reduce => (8/7)
  # @see to_r
  #
  def fraction_reduce
    self.class.new(to_r)
  end

  # @return [Tonal::Ratio] copy of self reduced to the given equave
  # @example
  #   Tonal::Ratio.new(48,14).equave_reduce(3) => (8/7)
  # @param equave Numeric
  #
  def equave_reduce(equave=2/1r)
    self.class.new(*_equave_reduce(equave))
  end
  alias :reduce :equave_reduce
  alias :reduced :equave_reduce

  # @return [Tonal::Ratio] self reduced to the given equave
  # @example
  #   Tonal::Ratio.new(48,14).equave_reduce!(3) => (8/7)
  # @param equave Numeric
  #
  def equave_reduce!(equave=2/1r)
    @antecedent, @consequent = _equave_reduce(equave)
    self
  end
  alias :reduce! :equave_reduce!
  alias :reduced! :equave_reduce!

  # @return [Tonal::ReducedRatio] of self
  # @example
  #   Tonal::Ratio.new(1,9).to_reduced_ratio => (16/9)
  # 
  def to_reduced_ratio
    Tonal::ReducedRatio.new(reduced_antecedent, reduced_consequent, equave: equave)
  end
  alias :reduced_ratio :to_reduced_ratio

  # @return [Tonal::Ratio] copy of self with the antecedent and precedent switched
  # @example
  #   Tonal::Ratio.new(3,2).invert => (2/3)
  #
  def invert
    self.class.new(consequent, antecedent)
  end
  alias :reflect :invert

  # @return [Tonal::Ratio] with antecedent and precedent switched
  # @example
  #   Tonal::Ratio.new(3,2).invert! => (2/3)
  #
  def invert!
    _initialize(consequent, antecedent, label: label, equave: equave)
    self
  end

  # @return [Tonal::Ratio] the mirror of self along the axis (default 1/1)
  # @example
  #   Tonal::ReducedRatio.new(4,3).mirror => (3/2)
  # @param axis
  #
  def mirror(axis=1/1r)
    (self.class.new(axis) ** 2) / self
  end

  # @return [Tonal::ReducedRatio] the Ernst Levy negative of self
  # @example
  #   Tonal::ReducedRatio.new(7/4r).negative => (12/7)
  #
  def negative
    self.class.new(3/2r) / self
  end

  # ==================================
  # Ratio grid transformations
  # numerator mapped on x-axis,
  # denominator mapped on y-axis
  # ==================================
  #
  # @return [Tonal::Ratio] with the antecedent and consequent translated by x and y
  # @example
  #   Tonal::Ratio.new(3,2).translate(3,3) => (6/5)
  # @param x [Numeric]
  # @param y [Numeric]
  #
  def translate(x=1, y=0)
    raise_if_negative(x,y)
    self.class.new(*(Vector[antecedent, consequent] + Vector[x, y]))
  end

  # @return [Tonal::Ratio] self scaled by given arguments
  # @example
  #   Tonal::Ratio.new(3,2).scale(2**5) => (96/64)
  # @param a [Numeric]
  # @param b [Numeric]
  #
  def scale(a, b=a)
    raise_if_negative(a,b)
    self.class.new(*(Matrix[[a, 0],[0, b]] * Vector[antecedent, consequent]))
  end

  # @return [Tonal::Ratio] self sheared by given arguments
  # @example
  #   Tonal::Ratio.new(3,2).shear(1, 3) => (14/11)
  # @param a [Numeric]
  # @param b [Numeric]
  #
  def shear(a, b=a)
    raise_if_negative(a,b)
    self.class.new(*((Matrix[[1,a],[0,1]] * Matrix[[1,0], [b,1]]) * Vector[antecedent, consequent]))
  end

  # @return [Float] degrees of antecedent (x) and consequent (y) on a 2D plane
  # @example
  #    Tonal::Ratio.new(3,2).planar_degrees => 33.69
  # @param round
  #
  def planar_degrees(round: PRECISION)
    (Math.atan2(consequent, antecedent) * 180/Math::PI).round(round)
  end

  # @return [Float] radians
  # @example
  #   Tonal::Ratio.new(3,2).planar_radians => 0.59
  # @param round
  #
  def planar_radians(round: PRECISION)
    Math.atan2(consequent, antecedent).round(round)
  end

  # @return [Array], self decomposed into its prime factors
  # @example
  #   Tonal::Ratio.new(31/30r).prime_divisions => [[[31, 1]], [[2, 1], [3, 1], [5, 1]]]
  #
  def prime_divisions
    [antecedent.prime_division, consequent.prime_division]
  end

  # @return [Vector], self represented as a prime vector
  # @example
  #   Tonal::Ratio.new(3/2r).prime_vector => Vector[-1, 1]
  #
  def prime_vector
    pds = prime_divisions
    return nil if pds.all?(&:empty?)

    max = [pds.first.max{|p| p.first}, pds.last.max{|p| p.first}].compact.max.first

    pds.last.collect!{|i| [i.first, -i.last]}

    p_arr = Prime.each(max).to_a
    Array.new(p_arr.count, 0).tap do |arr|
      pds.flatten(1).each{|e| arr[p_arr.find_index(e.first)] = e.last}
    end.to_vector
  end
  alias :monzo :prime_vector
  alias :prime_exponent_vector :prime_vector

  # @return [Integer] the maximum prime factor of self
  # @example
  #   Tonal::Ratio.new(31/30r).max_prime => 31
  #
  def max_prime
    prime_divisions.flatten(1).map(&:first).max
  end

  # @return [Integer] the minimum prime factor of self
  # @example
  #   Tonal::Ratio.new(31/30r).min_prime => 2
  #
  def min_prime
    prime_divisions.flatten(1).map(&:first).min
  end

  # @return [Boolean] whether self's max prime is within the given number
  # @example
  #   Tonal::Ratio.new(31/30r).max_prime_within?(7) => false
  # @param number to compare max prime against
  #
  def max_prime_within?(number)
    max_prime <= number
  end

  # @return [Integer] the product complexity of self
  # @example
  #   Tonal::ReducedRatio.new(3/2r).benedetti_height => 6
  #
  def benedetti_height
    reduced_antecedent * reduced_consequent
  end
  alias :product_complexity :benedetti_height

  # @return [Tonal::Log2] the log product complexity of self
  # @example
  #   Tonal::ReducedRatio.new(3/2r).tenney_height => 2.58
  #
  def tenney_height
    Tonal::Log2.new(logarithmand: benedetti_height)
  end
  alias :log_product_complexity :tenney_height
  alias :harmonic_distance :tenney_height

  # @return [Integer] the Weil height
  # @example
  #   Tonal::ReducedRatio.new(3/2r).weil_height => 3
  #
  def weil_height
    [reduced_antecedent, reduced_consequent].max
  end


  # @return [Tonal::Log2] the log of Weil height
  # @example
  #   Tonal::ReducedRatio.new(3/2r).log_weil_height => 1.58
  #
  def log_weil_height
    Tonal::Log2.new(logarithmand: weil_height)
  end

  # @return [Integer] the Wilson height. The sum of self's prime factors (greater than 2) times the absolute values of their exponents
  # @example
  #   Tonal::ReducedRatio.new(14/9r).wilson_height => 13
  #
  def wilson_height(prime_rejects: [2])
    benedetti_height.prime_division.reject{|p| prime_rejects.include?(p.first) }.sum{|p| p.first * p.last }
  end

  # @return [Tonal::Cents] the cents difference between self and its step in the given modulo
  # @example
  #   Tonal::ReducedRatio.new(3,2).efficiency(12) => -1.96
  # @param modulo against which the difference of self is compared
  #
  def efficiency(modulo)
    # We want the efficiency from the ratio (self).
    # If the step efficiency is X cents, then the ratio efficiency is -X cents.
    step(modulo).efficiency * -1.0
  end

  # @return [Array] the results of ratio dividing and multiplying self
  # @example
  #   Tonal::ReducedRatio.new(3/2r).div_times(5/4r) => [(6/5), (15/8)]
  # @param other_ratio to divide and multiple on self
  #
  def div_times(other_ratio)
    other_ratio = self.class.new(other_ratio)
    [self / other_ratio, self * other_ratio]
  end

  # @return [Array] the results of ratio subtracted and added to self
  # @example
  #   Tonal::ReducedRatio.new(3/2r).plus_minus(5/4r) => [(1/1), (11/8)]
  # @param other_ratio to add and subtract from self
  #
  def plus_minus(other_ratio)
    other_ratio = self.class.new(other_ratio)
    [self - other_ratio, self + other_ratio]
  end
  alias :min_plus :plus_minus

  # @return [Tonal::Cents] cent difference between self and other ratio
  # @example
  #   Tonal::ReducedRatio.new(3,2).cent_diff(4/3r) => 203.92
  # @param other_ratio [Tonal::ReducedRatio, Numeric] from which self's cents is measured
  #
  def cent_diff(other_ratio)
    cents - other_ratio.ratio.cents
  end

  # @return [String] symbolic representation of Tonal::Ratio
  #
  def label
    # Return label, if defined; or,
    # Return the "antecedent/consequent", if antecedent is less than 7 digits long; or
    # Return the floating point representation rounded to 2 digits of precision
    (@label || ((Math.log10(antecedent).to_i + 1) <= 6 ? "#{antecedent}/#{consequent}" : to_f.round(PRECISION))).to_s
  end

  # @return [String] the string representation of Tonal::Ratio
  # @example
  #   Tonal::Ratio.new(3, 2).inspect => "(3/2)"
  #
  def inspect
    "(#{antecedent}/#{consequent})"
  end
  alias :to_s :inspect

  def +(rhs)
    operate(rhs, :+)
  end

  def -(rhs)
    operate(rhs, :-)
  end

  def *(rhs)
    operate(rhs, :*)
  end

  def /(rhs)
    operate(rhs, :/)
  end

  def **(rhs)
    operate(rhs, :**)
  end

  # @return [Tonal::Ratio] the mediant (Farey) sum of self and another number
  # @example
  #   Tonal::Ratio.new(3,2).mediant_sum(4/3r) => (7/5)
  # @param number [Numeric, Tonal::Ratio]
  #
  def mediant_sum(number)
    self.class.new(antecedent + number.numerator, consequent + number.denominator)
  end
  alias :mediant :mediant_sum
  alias :farey_sum :mediant_sum

  # ==================================
  # Measurements
  # ==================================

  # @return [Integer] the least common multiple with self's denominator and the given number's denominator
  # @example
  #   Tonal::Ratio.new(3/2r).lcm(5/4r) => 4
  # @param lhs [Numeric, Tonal::Ratio] the number with which the lcm with self is computed
  #
  def lcm(lhs)
    [self.denominator, lhs.denominator].lcm
  end

  # @return [Tonal::Interval] between ratio (upper) and self (lower)
  # @example
  #   Tonal::ReducedRatio.new(133).interval_with(3/2r)
  #   => (192/133) ((3/2) / (133/128))
  # @param upper ratio
  # @param lower ratio
  #
  def interval_with(upper, lower=nil)
    r = self.class.new(upper, lower)
    Tonal::Interval.new(self, r)
  end

  # @return [Tonal::Cents] difference between ratio (upper) and self (lower)
  # @example
  #   Tonal::ReducedRatio.new(133).cents_difference_with(3/2r)
  #   => 635.62
  # @param upper ratio
  # @param lower ratio
  #
  def cents_difference_with(upper, lower=nil)
    interval_with(upper, lower).to_cents
  end

  # @return [Integer] the difference between antecedent and consequent
  # @example
  #   Tonal::ReducedRatio.new(3,2).difference => 1
  #
  def difference
    antecedent - consequent
  end
  alias :diff :difference

  # @return [Integer] the sum of antecedent and consequent
  # @example
  #   Tonal::ReducedRatio.new(3,2).combination => 5
  #
  def combination
    antecedent + consequent
  end
  alias :comb :combination

  def <=>(rhs)
    left = consequent == 0 ? Float::INFINITY : Rational(antecedent, consequent)
    right = rhs.denominator == 0 ? Float::INFINITY : Rational(rhs.numerator, rhs.denominator)
    left <=> right
  end

  private
  def _initialize(antecedent, consequent=nil, label: nil, equave: 2/1r)
    if consequent
      @antecedent = antecedent.abs
      @consequent = consequent.abs
    else
      antecedent = antecedent.abs
      @antecedent = antecedent.numerator
      @consequent = antecedent.denominator
    end
    @equave = equave
    @reduced_antecedent, @reduced_consequent = _equave_reduce(equave)
    @label = label
    @approximation = Approximation.new(ratio: self)
  end

  def raise_if_negative(*args)
    raise ArgumentError, "Arguments must be greater than zero" if args.any?{|i| i < 0 }
  end

  def _equave_reduce(equave=2/1r)
    case to_r
    when Float::INFINITY
      ante, cons = antecedent, 0
    when 1
      ante, cons = 1, 1
    when 0
      ante, cons = 0, consequent
    else
      power = (equave == Tonal::ReducedRatio::IDENTITY_RATIO) ? Tonal::ReducedRatio::IDENTITY_RATIO : Math.log(to_f.abs, equave)
      r = Rational(self, equave**(power - 1).ceil)
      r = 1/1r if r == Tonal::Interval::INTERVAL_OF_EQUIVALENCE
      ante, cons = r.numerator, r.denominator
    end
  end

  def coerce(other)
    [self.class.new(other), self]
  end

  def operate(rhs, op)
    klass = (rhs.class == Tonal::ReducedRatio || self.class == Tonal::ReducedRatio) ? Tonal::ReducedRatio : Tonal::Ratio

    case op
    when :*
      klass.new(antecedent * rhs.antecedent, consequent * rhs.consequent)
    when :/
      klass.new(antecedent * rhs.consequent, consequent * rhs.antecedent)
    when :+, :-
      lcm = self.denominator.lcm(rhs.denominator)
      left = (self.to_r * lcm).numerator
      right = (rhs.to_r * lcm).numerator
      klass.new((left).send(op, right).abs, lcm)
    when :**
      klass.new(Rational(antecedent, consequent) ** rhs.to_r)
    end
  end
end

module Ratio
  def self.[](u, l=nil)
    Tonal::Ratio.new(u, l)
  end
end

