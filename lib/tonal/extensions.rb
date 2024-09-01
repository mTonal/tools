class Prime
  # @return [Array] the primes within lower and upper bounds
  # @example
  #   Prime.within(6, 14) => [7, 11, 13]
  # @param lower bound
  # @param upper bound
  #
  def self.within(lower=0, upper) = self.each(upper).reject{|p| p < lower}
end

class Numeric
  # @return [Numeric] translated modularly
  # @example
  #   Math::PI.modulo_translate(-3, 3) => -2.858407346410207
  # @param lower the lower bound of the modulo range
  # @param upper the upper bound of the modulo range
  #
  def modulo_translate(lower=0, upper)
    range = (upper - lower) == 0 ? 1 : upper - lower
    (self - lower) % range + lower
  end

  # @return [Array] a tuple of self offset positively/negatively
  # @example
  #   Math::PI.plus_minus(3)
  #     => [6.141592653589793, 0.14159265358979312]
  # @param offset plus and minus distance from self
  #
  def plus_minus(offset) = [self + offset, self - offset]
  alias :min_plus :plus_minus

  # @return [Array] a tuple of self divided and multiplied by factor
  # @example
  #   Math::PI.div_times(3) => [1.0471975511965976, 9.42477796076938]
  # @param factor [Numeric]
  #
  def div_times(factor) = [self / factor, self * factor]

  # @return [Tonal::ReducedRatio] the octave reduced ratio of self
  # @example
  #   (2**(1.0/12)).ratio => (4771397596969315/4503599627370496)
  #
  def to_ratio(reduced: true, equave: 2/1r) = reduced ? Tonal::ReducedRatio.new(self, equave: equave) : Tonal::Ratio.new(self, equave: equave)
  alias :ratio :to_ratio

  # @return [Float], the degrees on a circle of self
  # @example
  #   (2**(6.0/12)).period_degrees => 180.0
  #
  def period_degrees = self.ratio.period_degrees

  # @return [Tonal::Log] the log of self to the given base
  # @example
  #   (3/2r).log(10) => 0.17609125905568124
  #
  def log(base) = Tonal::Log.new(logarithmand: self, base: base)

  # @return [Tonal::Log2] the log2 of self
  # @example
  #   (3/2r).log2 => 0.5849625007211562
  #
  def log2 = Tonal::Log2.new(logarithmand: self)
  alias :to_log2 :log2
  alias :span :log2

  # @return [Tonal::Cents] of self interpreted as a cents quantity
  # @example
  #   700.0.cents => 700.0
  #
  def cents = Tonal::Cents.new(cents: self)

  # @return [Tonal::Cents] of self interpreted as a cents quantity
  # @example
  #   700.0.¢ => 700.0
  #
  def ¢ = cents

  # @return [Tonal::Cents] of self interpreted as a ratio
  # @example
  #   (3/2r).to_cents => 701.96
  #
  def to_cents = self.log2.to_cents

  # @return [Tonal::Hertz] of self
  #
  def hz = Tonal::Hertz.new(self)
  alias :to_hz :hz

  # @return [Tonal::Step] the step of self in the given modulo
  # @example
  #   (5/4r).step(12) => 4\12
  # @param modulo
  #
  def step(modulo=12) = to_log2.step(modulo)

  # @return [Float] the log product complexity of self
  # @example
  #   (3/2r).benedetti_height => 6
  #
  def benedetti_height = self.ratio.benedetti_height
  alias :product_complexity :benedetti_height

  # @return [Integer] the product complexity of self
  # @example
  #   (3/2r).tenney_height => 2.584962500721156
  #
  def tenney_height = self.ratio.tenney_height
  alias :log_product_complexity :tenney_height

  # @return [Integer] the Weil height
  # @example
  #   (3/2r).weil_height => 3
  #
  def weil_height = self.ratio.weil_height

  # @return [Tonal::Log2] the log of Weil height
  # @example
  #   (3/2r).log_weil_height => 1.5849625007211563
  #
  def log_weil_height = self.ratio.log_weil_height

  # @return [Integer] the Wilson height
  # @example (14/9r).wilson_height => 13
  #
  def wilson_height(reduced: true, equave: 2/1r, prime_rejects: [2]) = self.ratio(reduced: reduced, equave: equave).wilson_height(prime_rejects: prime_rejects)

  # @return [Float] the cents difference between self and its step in the given modulo
  # @example
  #   (3/2r).efficiency(12) => -1.955000865387433
  # @param modulo
  #
  def efficiency(modulo) = (Tonal::Cents::CENT_SCALE * step(modulo).step / modulo.to_f) - to_cents

  # @return [Tonal::Interval] beween self (upper) and ratio (lower)
  # @example
  #   (133).interval_with(3/2r) => 133/96 (133/128 / 3/2)
  # @param ratio
  #
  def interval_with(ratio) = Tonal::Interval.new(self.ratio, ratio)

  # @return [Vector], self represented as a prime vector
  # @example
  #   (3/2r).prime_vector => Vector[-1, 1]
  #
  def prime_vector = self.ratio.prime_vector
  alias :monzo :prime_vector

  # @return [Array], self decomposed into its prime factors
  # @example
  #   (31/30r).prime_divisions => [[[31, 1]], [[2, 1], [3, 1], [5, 1]]]
  #
  def prime_divisions = [self.numerator.prime_division, self.denominator.prime_division]

  # @return [Integer] the maximum prime factor of self
  # @example
  #   (31/30r).max_prime => 31
  #
  def max_prime = prime_divisions.flatten(1).map(&:first).max

  # @return [Integer] the minimum prime factor of self
  # @example
  #   (31/30r).min_prime => 2
  #
  def min_prime = prime_divisions.flatten(1).map(&:first).min

  # @return [Vector], self expressed as a Vector
  # @example
  #   (3/2r).to_vector => Vector[3, 2]
  #
  def to_vector = Vector[self.numerator, self.denominator]
  alias :vector :to_vector

  # @return [Tonal::ReducedRatio], the Ernst Levy negative of self
  # @example
  #  (7/4r).negative => (12/7)
  #
  def negative = self.ratio.negative

  # @return [Tonal::ReducedRatio], the ratio rotated on the given axis, default 1/1
  # @example
  #   (3/2r).mirror => (4/3)
  #
  def mirror(axis=1/1r) = self.ratio.mirror(axis)
end

class Integer
  alias :prime_factors :prime_division

  # @return [Integer] the maximum prime factor of self
  # @example
  #  72.max_prime => 3
  #
  def max_prime = self.prime_division.map(&:first).max

  # @return [Integer] the minimum prime factor of self
  # @example
  #   72.min_prime => 2
  #
  def min_prime = self.prime_division.map(&:first).min

  # @return [Integer] the factorial of self
  # @example
  #   5.factorial => 120
  #
  def factorial = (2..self).reduce(1, :*)

  # @return [Boolean] if self is coprime with i
  # @example
  #   25.coprime?(7) => true
  #   25.coprime?(5) => false
  #
  def coprime?(i) = self.gcd(i) == 1

  # @return [Array] list of integers that are coprime with self, up to the value of self
  # @example
  #   10.coprimes => [1, 3, 7, 9]
  #
  def coprimes
    [].tap do |coprime_set|
      1.upto(self) do |i|
        coprime_set << i if i.coprime?(self)
      end
    end
  end

  # @return [Integer] the count of coprimes less than self
  # @example
  #   10.phi => 4
  #
  def phi = coprimes.count
  alias :totient :phi

  # @return [Array] of integers that are n-smooth with self
  #   Adapted from https://rosettacode.org/wiki/N-smooth_numbers#Ruby
  # @example
  #   5.nsmooth(25)
  #   => [1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 18, 20, 24, 25, 27, 30, 32, 36, 40, 45, 48, 50, 54]
  # @param limit
  #
  def nsmooth(limit=2)
    ([0] * limit).tap do |ns|
      primes = Prime.each(self).to_a
      ns[0] = 1
      nextp = primes[0..primes.index(self)]

      indices = [0] * nextp.size
      (1...limit).each do |m|
        ns[m] = nextp.min
        (0...indices.size).each do |i|
          if ns[m] == nextp[i]
            indices[i] += 1
            nextp[i] = primes[i] * ns[indices[i]]
          end
        end
      end
    end
  end
end

class Array
  # @return [Array] self replaced by array padded to the right up to n, with value. value default is nil
  # @example
  #   [3,2].rpad!(3, 12) => [3, 2, 12]
  # @param min_size
  # @param value
  #
  def rpad!(min_size, value = nil)
    self.length > min_size ? self : (min_size - self.length).times { self << value }
    self
  end

  # @return [Array] padded to the right up to n, with value. value default is nil
  # @example
  #   [3,2].rpad(3, 12) => [3, 2, 12]
  # @param min_size
  # @param value
  #
  def rpad(min_size, value = nil) = self.dup.rpad!(min_size, value)

  # @return [Vector] self converted to a vector
  # @example
  #   [3,2].to_vector => Vector[3, 2]
  #
  def to_vector = Vector[*self]
  alias :vector :to_vector

  # @return [Integer] least common multiple of integer elements of self
  # @example
  #   [3, 2, 7].lcm => 42
  #
  def lcm = self.reduce(1, :lcm)

  # @return [Array] of numerators of elements of self
  # @example
  #   [3/2r, 5/4r].numerators => [3, 5]
  #
  def numerators = self.map(&:numerator)
  alias :antecedents :numerators

  # @return [Array] of denominators of elements of self
  # @example
  #   [Tonal::Ratio.new(3,2), Tonal::Ratio.new(5,4)].denominators => [2, 4]
  #
  def denominators = self.map(&:denominator)
  alias :consequents :denominators

  # @return [Array] an array of ratios with equalized denominators
  # @example
  #   [4/3r, 3/2r].denominize => [(8/6), (9/6)]
  #
  def denominize
    l = denominators.lcm
    map{|r| Tonal::Ratio.new(l / r.denominator * r.numerator, l)}
  end

  # @return [Array] of cent values for ratio or rational elements of self
  # @example
  #   [3/2r, 4/3r].to_cents => [701.96, 498.04]
  #
  def to_cents = self.map{|r| r.to_cents}
  alias :cents :to_cents

  # @return [Float] the mean of the elements of self
  # @example
  #   [1, 2].mean => 1.5
  #
  def mean = self.sum / self.count.to_f

  # @return [Tonal::ReducedRatio] ratio reconstructed from the result of a prime factor decomposition
  # @example
  #   [[[3, 1]], [[2, 1]]].ratio_from_prime_divisions => (3/2)
  # @param reduced [Boolean] if a reduced or unreduced ratio is returned
  #
  def ratio_from_prime_divisions(reduced: false) = reduced ? Tonal::ReducedRatio.new(Prime.int_from_prime_division(self.first), Prime.int_from_prime_division(self.last)) : Tonal::Ratio.new(Prime.int_from_prime_division(self.first), Prime.int_from_prime_division(self.last))

  # @return [Array] translated by value
  # @example
  #   [0.24184760813024642, 0.49344034900361244, 0.07231824070126536].translate(-0.07231824070126536) = [0.16952936742898106, 0.4211221083023471, 0.0]
  # @param value [Numeric] the value that is translating self
  #
  def translate(value) = self.map{|e| e + value}


  # @return [Array] rescaled by new minimum and new maximum
  # @example
  #   [0.47943068514319154, 0.7161083818132802, 0.19855867360591783].rescale(0,3)
  #   => [1.6280871600341376, 3.0, 0.0]
  # @param new_min
  # @param new_max
  #
  def rescale(new_min=0, new_max)
    old_min = min
    old_max = max

    self.map do |x|
      new_min + ((x - old_min) * (new_max - new_min)) / (old_max - old_min)
    end
  end

  # @return [Array] translated modularly
  # @example
  #   [-6.617469071022061, 4.755369851099594, 7.588140911919945, -6.49706614430203].modulo_translate(-3, 5)
  #   => [1.382530928977939, 4.755369851099594,-0.411859088080055,  1.50293385569797]
  # @param lower the lower bound of the modulo range
  # @param upper the upper bound of the modulo range
  #
  def modulo_translate(lower=0, upper)
    range = (upper - lower) == 0 ? 1 : upper - lower
    map do |value|
      (value - lower) % range + lower
    end
  end
end

class Vector
  # @return [Tonal::Ratio]
  # @example
  #   Vector[3,2].ratio => (3/2)
  # @param reduced
  # @param equave
  #
  def to_ratio(reduced: true, equave: 2/1r) = reduced ? Tonal::ReducedRatio.new(*self, equave: equave) : Tonal::Ratio.new(*self, equave: equave)
  alias :ratio :to_ratio
end

module Math
  # @return [Integer] the factorial of n
  # @example
  #   Math.factorial(10) => 3628800
  # @param limit
  #
  def self.factorial(limit) = (2..limit).reduce(1, :*)

  PHI = (1 + 5**(1.0/2))/2
end

