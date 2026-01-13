require "spec_helper"

RSpec.describe "Extensions" do
  describe "Prime extensions" do
    describe ".within(lower, upper)" do
      it "returns primes within the upper and lower bounds" do
        expect(Prime.within(6, 14)).to eq [7, 11, 13]
      end
    end
  end

  describe "Numeric extensions" do
    describe "#modulo_translate" do
      it "translates the number within the give modulo range" do
        expect(Math::PI.modulo_translate(-3, 3)).to eq(-2.858407346410207)
      end
    end

    describe "#plus_minus" do
      it "returns a tuple with the given argument added and subtracted from self" do
        expect(5.plus_minus(2)).to eq [7, 3]
      end
    end

    describe "div_times" do
      it "returns a tuple with the given argument divided and multiplied into self" do
        expect((3/2r).div_times(9/8r)).to eq [4/3r, 27/16r]
      end
    end

    describe "#to_ratio" do
      it "returns the unreduced octave ratio of self" do
        expect(0.75.to_ratio).to eq 3/4r
      end

      context "when reduced is sent" do
        it "returns a reduced ratio" do
          expect(0.75.to_ratio(reduced: true)).to eq 3/2r
        end
      end
    end

    describe "#period_degrees" do
      it "returns the degrees on a period circle of self" do
        expect((2**(6.0/12)).period_degrees).to eq 180.0
      end
    end

    describe "#log" do
      it "returns the log to the base b of self" do
        expect((3/2r).log(10)).to eq 0.17609125905568124
      end
    end

    describe "#log2" do
      it "returns the log2 of self" do
        expect((3/2r).log2).to eq 0.5849625007211562
      end
    end

    describe "#to_cents" do
      it "returns the cents value of self" do
        expect((3/2r).to_cents).to eq 701.96
      end
    end

    describe "#cents" do
      it "returns self as an instance of Tonal::Cents" do
        expect(700.0.cents).to eq 700.0
      end
    end


    describe "#¢" do
      it "returns self as an instance of Tonal::Cents" do
        expect(700.0.¢).to eq 700.0
      end
    end

    describe "#hz" do
      it "returns self as a Tonal::Hertz object" do
        expect(1.5.hz).to eq 1.5
        expect(1.5.hz).to be_a_kind_of(Tonal::Hertz)
      end
    end

    describe "#scale_step" do
      it "returns the step for the given modulo" do
        expect((3/2r).scale_step(31)).to eq Tonal::Step.new(modulo: 31, ratio: 3/2r)
      end

      context "without an argument" do
        it "returns the step for modulo 12" do
          expect((3/2r).scale_step).to eq Tonal::Step.new(modulo: 12, ratio: 3/2r)
        end
      end
    end

    describe "#prime_divisions" do
      it "returns the prime divisions of the number" do
        expect((31/30r).prime_divisions).to eq [[[31, 1]], [[2, 1], [3, 1], [5, 1]]]
      end

      context "with unreduced ratios" do
        it("returns the prime divisions of the unreduced ratio") { expect((36/13r).prime_divisions).to eq [[[2, 2], [3, 2]], [[13, 1]]] }
      end
    end

    describe "#max_prime" do
      it "maximum prime of self" do
        expect((31/30r).max_prime).to eq 31
      end
    end

    describe "#min_prime" do
      it "minimal prime of self" do
        expect((31/30r).min_prime).to eq 2
      end
    end

    describe "#prime_vector" do
      it "returns the prime vector of the number" do
        expect((3/2r).prime_vector).to eq Vector[-1, 1]
      end
    end

    describe "#benedetti_height" do
      it "returns the product complexity of the number" do
        expect((3/2r).benedetti_height).to eq 6
      end
    end

    describe "#tenney_height" do
      it "returns the log product complexity of the number" do
        expect((3/2r).tenney_height).to eq 2.584962500721156
      end
    end

    describe "#weil_height" do
      it "returns the Weil height of the number" do
        expect((3/2r).weil_height).to eq 3
      end
    end

    describe "#log_weil_height" do
      it "returns the log Weil height of the number" do
        expect((3/2r).log_weil_height).to eq 1.5849625007211563
      end
    end

    describe "#wilson_height" do
      it "returns the sum of self's prime factors (greater than 2) times the absolute values of their exponents" do
        expect((14/9r).wilson_height).to eq 13
      end

      context "when prime_rejects is blank" do
        it "returns the value conforming to the Xenwiki definition" do
          expect((14/9r).wilson_height(prime_rejects: [])).to eq 15
        end
      end

      context "when self is an integer, equave is 1 and prime rejects is blank" do
        it "returns the value conforming to the Xenwiki definition for the integer" do
          expect(6480.wilson_height(equave: 1, prime_rejects: [])).to eq 25
        end
      end
    end

    describe "#efficiency" do
      it "returns the difference between self and its step for a given modulo" do
        expect((3/2r).efficiency(12)).to eq(-1.96)
      end
    end

    describe "#interval_with" do
      it "returns the interval between self and the given ratio" do
        expect((3/2r).interval_with(7/4r)).to eq Tonal::Interval.new(3/2r, 7/4r)
      end
    end

    describe "#to_interval" do
      it "returns the interval between 1/1 and self" do
        expect((3/2r).to_interval).to eq Tonal::Interval.new(3/2r, 1/1r)
      end
    end

    describe "#cents_difference_with" do
      it "returns the cents difference between self and the given ratio" do
        expect((3/2r).cents_difference_with(1/1r)).to eq 701.96
      end
    end

    describe "#negative" do
      it "returns the Ernst Levy negative of self" do
        expect(1.75.negative).to eq 12/14r
      end
    end

    describe "#mirror" do
      it "returns self rotated on 1/1 by default" do
        expect((3/2r).mirror).to eq 2/3r
      end

      it "rotates self around given axis" do
        expect((3/2r).mirror(9/8r)).to eq 162/192r
      end
    end

    describe "#log_floor" do
      it "returns the log floor to the base 10 of self" do
        expect(22632.log_floor).to eq 4
      end

      context "with given base" do
        it "returns the log floor to the given base of self" do
          expect(22632.log_floor(2)).to eq 14
        end
      end
    end

    describe "#reciprocal" do
      it "returns the reciprocal of self" do
        expect((3/2r).reciprocal).to eq (2/3r)
      end
    end

    describe "#root" do
      it "returns self raised to the given root" do
        expect((3/2r).root(2)).to eq 1.224744871391589
      end
    end

    describe "#power" do
      it "returns self raised to the given power/root" do
        expect((3/2r).power(3,2)).to eq 1.8371173070873832
      end
    end
  end

  describe "Rational extensions" do
    describe "#to_vector" do
      it "returns self as a Vector" do
        expect((3/2r).to_vector).to eq Vector[3, 2]
      end
    end
  end

  describe "Integer extensions" do
    describe "#max_prime" do
      it "returns the maximum prime factor" do
        expect(72.max_prime).to eq 3
      end
    end

    describe "#min_prime" do
      it "returns the minimum prime factor" do
        expect(72.min_prime).to eq 2
      end
    end

    describe "#edo" do
      it "returns the numeric 2**(self/modulo)" do
        expect(1.edo(12)).to eq 1.0594630943592953
      end
    end

    describe "#factorial" do
      it "return the factorial of self" do
        expect(5.factorial).to eq 120
      end
    end

    describe "#coprime?(n)" do
      it "returns boolean if self is coprime with n" do
        expect(25.coprime?(7)).to be true
      end
    end

    describe "#coprimes" do
      it "returns list of integers that are coprime with self" do
        expect(10.coprimes).to eq [1, 3, 7, 9]
      end
    end

    describe "#superparticular" do
      it "returns the superparticular ratio base on self as the numerator" do
        expect(4.superparticular).to eq (4/3r)
      end

      context "when the integer is less than 2" do
        it "returns nil" do
          expect([-1,0,1].sample.superparticular).to eq nil
        end
      end
    end

    describe "#phi" do
      it "returns the count of coprimes less than self" do
        expect(10.phi).to eq 4
      end
    end

    describe "#nsmooth(n)" do
      it "returns the set of largest prime factors less than or equal to self" do
        expect(5.nsmooth(25)).to eq [1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 18, 20, 24, 25, 27, 30, 32, 36, 40, 45, 48, 50, 54]
      end
    end

    describe "#prime_signature" do
      it "returns the prime signature of self" do
        expect(24.prime_signature).to eq [1, 3]
      end
    end
  end

  describe "Array extensions" do
    describe "#to_r" do
      it "returns a Rational from the first and last elements of array" do
        expect([4,3].to_r).to eq 4/3r
      end
    end

    describe "#rpad" do
      it "grows array to the right up to size n, with value v" do
        expect([2, 3].rpad(4, 12)).to eq [2, 3, 12, 12]
      end
    end

    describe "#to_vector" do
      it "returns Vector of self" do
        expect([3,2].to_vector).to eq Vector[3,2]
      end
    end

    describe "#numerators" do
      it "returns the numerators for an array of rationals or ratios" do
        expect([3/2r, 5/4r].numerators).to eq [3, 5]
      end
    end

    describe "#denominators" do
      it "returns the denominators for an array of rationals or ratios" do
        expect([Tonal::Ratio.new(3,2), Tonal::Ratio.new(5,4)].denominators).to eq [2, 4]
      end
    end

    describe "#denominize" do
      it "returns an array of ratios with equalized denominators" do
        expect([4/3r, 3/2r].denominize).to eq [Tonal::Ratio.new(8,6), Tonal::Ratio.new(9,6)]
      end
    end

    describe "#to_cents" do
      it "returns cent values for ratio or rational elements of self" do
        expect([3/2r, 4/3r].to_cents).to eq [701.96, 498.04]
      end
    end

    describe "#to_interval" do
      context "with two elements" do
        it "returns the interval between the first and second elements of the array" do
          expect([3/2r, 7/4r].to_interval).to eq Tonal::Interval.new(3/2r, 7/4r)
        end
      end

      context "with four elements" do
        it "returns the interval between the first pair and the second pair of elements of the array" do
          expect([2,3,3,4].to_interval).to eq Tonal::Interval.new(2,3,3,4)
        end
      end

      context "with one element" do
        it "takes the first element as the upper ratio and 1/1 as the lower ratio" do
          expect([3].to_interval).to eq Tonal::Interval.new(3/2r, 1/1r)
        end
      end
    end

    describe "#mean" do
      it "returns the mean of elements of the array" do
        expect([1, 2].mean).to eq 1.5
      end
    end

    describe "#ratio_from_prime_divisions" do
      it "returns the ratio constructed from prime division arrays" do
        expect([[[3, 1]], [[2, 1]]].ratio_from_prime_divisions).to eq 3/2r
      end
    end

    describe "#best_fitting_edo" do
      it "returns a tuple with the first number the EDO that best fits the given ratios and the second number the error of the fit" do
        expect([3/2r].best_fitting_edo).to eq [53, 0.07]
      end
    end

    describe "#translate" do
      it "translates the values of array the given amount" do
        expect([0.24184760813024642, 0.49344034900361244, 0.07231824070126536].translate(-0.07231824070126536)).to eq [0.16952936742898106, 0.4211221083023471, 0.0]
      end
    end

    describe "#rescale" do
      it "rescales the array by the given minimum/maximum" do
        expect([0.24184760813024642, 0.49344034900361244, 0.07231824070126536].rescale(0,3)).to eq [1.207697464132658, 3.0, 0.0]
      end
    end

    describe "#modulo_translate" do
      it "translates the array's elements within the modulo range" do
        expect([-6.617469071022061, 4.755369851099594, 7.588140911919945, -6.49706614430203].modulo_translate(-3, 5)).to eq [1.382530928977939, 4.755369851099594, -0.411859088080055, 1.50293385569797]
      end
    end

    describe "#to_efr" do
      it "returns an ExtendedRatio constructed from the array elements" do
        efr = [1/1r, 5/4r, 3/2r].to_efr
        expect(efr).to be_a_kind_of(Tonal::ExtendedRatio)
        expect(efr.inspect).to eq "4:5:6"
      end

      context "when as is :partials" do
        it "returns an ExtendedRatio constructed from the array elements as partials" do
          efr = [4, 5, 6].to_efr(as: :partials)
          expect(efr).to be_a_kind_of(Tonal::ExtendedRatio)
          expect(efr.inspect).to eq "4:5:6"
        end
      end
    end

    describe "#to_sefr" do
      it "returns a SubharmonicExtendedRatio constructed from the array elements" do
        sefr = [1/1r, 5/4r, 3/2r].to_sefr
        expect(sefr).to be_a_kind_of(Tonal::SubharmonicExtendedRatio)
        expect(sefr.inspect).to eq "15:12:10"
      end

      context "when as is :partials" do
        it "returns a SubharmonicExtendedRatio constructed from the array elements as partials" do
          sefr = [4, 5, 6].to_sefr(as: :partials)
          expect(sefr).to be_a_kind_of(Tonal::SubharmonicExtendedRatio)
          expect(sefr.inspect).to eq "6:5:4"
        end
      end
    end
  end

  describe "Range extensions" do
    describe "#to_efr" do
      it "returns an ExtendedRatio constructed from the range elements" do
        er = (4..7).to_efr
        expect(er).to be_a_kind_of(Tonal::ExtendedRatio)
        expect(er.inspect).to eq "4:5:6:7"
      end
    end
  end

  describe "Vector extensions" do
    describe "#to_ratio" do
      it "returns a Tonal::Ratio by default" do
        expect(Vector[6,4].to_ratio).to be_a_kind_of(Tonal::Ratio)
      end

      context "when reduced is false" do
        it "returns a Tonal::Ratio" do
          expect(Vector[6,4].to_ratio(reduced: true)).to be_a_kind_of(Tonal::ReducedRatio)
        end
      end
    end
  end

  describe "Math extensions" do
    describe ".factorial(n)" do
      it "returns the factorial of n" do
        expect(Math.factorial(10)).to eq 3628800
      end
    end
  end
end
