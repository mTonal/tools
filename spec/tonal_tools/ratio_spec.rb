require "spec_helper"

RSpec.describe Tonal::Ratio do
  subject { described_class.new(arg1, arg2) }

  describe "initialization" do
    let(:arg1) { [ 3/2r, 1.5, Math::PI ].sample }
    let(:arg2) { 2 }

    context "without a first argument" do
      let(:arg1) { nil }
      let(:arg2) { nil }

      it "raises an exception" do
        expect{ subject }.to raise_error(ArgumentError, "Antecedent must be Numeric")
      end
    end

    context "with one argument" do
      subject { described_class.new(arg1) }

      it "sets the antecedent to the argument's numerator and the consequent to its denominator" do
        expect(subject.antecedent).to eq arg1.numerator
        expect(subject.consequent).to eq arg1.denominator
      end
    end

    context "with two arguments" do
      it "sets the antecedent to the first argument and consequent to the second argument" do
        expect(subject.antecedent).to eq arg1
        expect(subject.consequent).to eq arg2
      end
    end

    context "with a single negative real" do
      context "with a negative real" do
        let(:arg1) { -1.5 }
        let(:arg2) { nil }

        it "returns a positive ratio" do
          expect(subject.antecedent).to eq 3
          expect(subject.consequent).to eq 2
        end
      end

      context "with a negative integers" do
        let(:arg1) { -3 }
        let(:arg2) { 2 }

        it "returns a positive ratio" do
          expect(subject.antecedent).to eq 3
          expect(subject.consequent).to eq 2
        end
      end
    end
  end

  describe ".superparticular" do
    let(:n) { rand(100)+1 }

    it "returns a ratio who's numerator and denominator are one apart" do
      expect(described_class.superparticular(n)).to eq described_class.new(n, n-1)
    end
  end

  describe ".superpartient" do
    let(:n) { rand(100)+1 }
    let(:partient) { rand(10) }

    it "returns a ratio who's numerator and denominator are a partient apart" do
      expect(described_class.superpartient(n, partient)).to eq described_class.new(n, n-partient)
    end
  end

  describe ".random_ratio" do
    it { expect(described_class.random_ratio).to be_a_kind_of(Tonal::Ratio) }
  end

  describe ".ed" do
    it { expect(described_class.ed(12, 7)).to eq 421735949569275/281474976710656r }
  end

  describe ".within_cents?" do
    it { expect(described_class.within_cents?(100.cents, 200.cents, 5)).to be false }
  end

  describe "#within_prime?" do
    it "returns true when the ratio's max prime is within the given prime" do
      expect(described_class.new(3/2r).within_prime?(7)).to be true
    end

    it "returns false when the ratio's max prime is greater than the given prime" do
      expect(described_class.new(13/8r).within_prime?(7)).to be false
    end
  end

  describe "conversions" do
    let(:arg1) { 3/2r }
    let(:arg2) { nil }

    describe "#to_a" do
      it "returns an array" do
        expect(subject.to_a).to be_a_kind_of(Array)
        expect(subject.to_a).to eq [3, 2]
      end
    end

    describe "#to_v" do
      it "returns a vector" do
        expect(subject.to_v).to eq Vector[3,2]
      end
    end

    describe "#to_r" do
      it "returns the Rational of self" do
        expect(subject.to_r).to be_a_kind_of(Rational)
        expect(subject.to_r).to eq 3/2r
      end

      context "when denominator is zero" do
        let(:arg2) { 0 }

        it "returns infinity" do
          expect(subject.to_r).to eq Float::INFINITY
        end
      end

      context "when numerator is infinity" do
        let(:arg1) { Float::INFINITY }

        it "returns infinity" do
          expect(subject.to_r).to eq Float::INFINITY
        end
      end
    end

    describe "#to_f" do
      it "returns the Float of self" do
        expect(subject.to_f).to be_a_kind_of(Numeric)
        expect(subject.to_f).to eq 1.5
      end

      context "when denominator is zero" do
        let(:arg2) { 0 }
        it "returns infinity" do
          expect(subject.to_f).to eq Float::INFINITY
        end
      end

      context "when numerator is infinity" do
        let(:arg1) { Float::INFINITY }
        it "returns infinity" do
          expect(subject.to_f).to eq Float::INFINITY
        end
      end
    end

    describe "#to_log" do
      it "returns the log of self" do
        expect(subject.to_log(3)).to be_a_kind_of(Tonal::Log)
        expect(subject.to_log(3)).to eq 0.36907024642854251
      end
    end

    describe "#to_log2" do
      it "returns the log2 of self" do
        expect(subject.to_log2).to be_a_kind_of(Tonal::Log2)
        expect(subject.to_log2).to eq 0.5849625007211562
      end
    end

    describe "#to_cents" do
      it "returns the cents of self" do
        expect(subject.to_cents).to be_a_kind_of(Tonal::Cents)
        expect(subject.to_cents).to eq 701.96
      end
    end

    describe "#step" do
      it "returns the step of self in a given modulo" do
        expect(subject.step).to eq Tonal::Step.new(modulo: 12, ratio: 3/2r)
      end
    end

    describe "#period_degrees" do
      it "returns the equave period degrees of self" do
        expect(subject.period_degrees).to eq 210.59
      end
    end

    describe "#period_radians" do
      it "returns the equave period radians of self" do
        expect(subject.period_radians).to eq 3.68
      end
    end

    describe "#fraction_reduce" do
      subject { described_class.new(6,9) }

      it "reduces to simplest rational form" do
        expect(subject).to eq described_class.new(6,9)
        expect(subject.fraction_reduce).to eq described_class.new(2,3)
      end
    end

    describe "#equave_reduce" do
      subject { described_class.new(6,9) }

      it "octave reduces by default" do
        expect(subject.equave_reduce).to eq described_class.new(4,3)
      end

      context "with an equave other than the octave" do
        let(:equave) { 5 }

        it "equave reduces" do
          expect(subject.equave_reduce(equave)).to eq(10/3r)
        end
      end
    end

    describe "#to_reduced_ratio" do
      it { expect(subject.to_reduced_ratio).to be_a_kind_of(Tonal::ReducedRatio) }
    end

    describe "#invert" do
      it "inverts the ratio" do
        expect(subject.invert).to eq 2/3r
      end
    end

    describe "#mirror" do
      it "mirrors self around the given axis" do
        expect(subject.mirror(1/1r)).to eq 2/3r
      end
    end

    describe "#negative" do
      it "returns the Ernst Levy negative of self" do
        expect(subject.negative).to eq 1/1r
      end
    end

    describe "#translate" do
      it "moves ratio a distance in the specified direction" do
        expect(subject.translate(1)).to eq described_class.new(4,2)
      end

      context "when argument is negative" do
        it "raises an exception" do
          expect{ subject.translate(-1) }.to raise_error(ArgumentError, "Arguments must be greater than zero")
        end
      end
    end

    describe "#scale" do
      it "scales the numerator and denominator by the given number" do
        expect(subject.scale(3)).to eq described_class.new(9,6)
      end

      context "when argument is negative" do
        it "raises an exception" do
          expect{ subject.scale(-1) }.to raise_error(ArgumentError, "Arguments must be greater than zero")
        end
      end
    end

    describe "#shear" do
      it "returns the affine shear transformation of self" do
        expect(subject.shear(1)).to eq 8/5r
      end

      context "when argument is negative" do
        it "raises an exception" do
          expect{ subject.shear(-1) }.to raise_error(ArgumentError, "Arguments must be greater than zero")
        end
      end
    end

    describe "#planar_degrees" do
      it "returns the x-y planar degrees of the point defined by antecedent and consequent" do
        expect(subject.planar_degrees).to eq 33.69
      end
    end

    describe "#planar_radians" do
      it "returns the x-y planar radians of the point defined by antecedent and consequent" do
        expect(subject.planar_radians).to eq 0.59
      end
    end
  end

  describe "measurements" do
    let(:arg1) { 3/2r }
    let(:arg2) { nil }

    describe "#prime_divisions" do
      it "returns the prime divisions of antecedent and consequent" do
        expect(subject.prime_divisions).to eq [[[3, 1]], [[2, 1]]]
      end
    end

    describe "#max_prime" do
      it "returns the max prime of ratio" do
        expect(subject.max_prime).to eq 3
      end
    end

    describe "#min_prime" do
      it "returns the min prime of ratio" do
        expect(subject.min_prime).to eq 2
      end
    end

    describe "#prime_vector" do
      it "returns the prime vector of the ratio" do
        expect(subject.prime_vector).to eq Vector[-1, 1]
      end
    end

    describe "#benedetti_height" do
      it "returns the product complexity of the ratio" do
        expect(subject.benedetti_height).to eq 6
      end
    end

    describe "#tenney_height" do
      it "returns the log product complexity of the ratio" do
        expect(subject.tenney_height).to eq 2.584962500721156
      end
    end

    describe "#weil_height" do
      it "returns the Weil height of the number" do
        expect(subject.weil_height).to eq 3
      end
    end

    describe "#wilson_height" do
      it "returns the Wilson height" do
        expect(subject.wilson_height).to eq 3
      end
    end

    describe "#log_weil_height" do
      it "returns the log Weil height of the number" do
        expect(subject.log_weil_height).to eq 1.5849625007211563
      end
    end

    describe "#efficiency" do
      it "returns the difference between self and its step for a given modulo" do
        expect(subject.efficiency(12)).to eq -1.9600000000000364
      end
    end

    describe "#div_times" do
      it "returns the result of self divided/multiplied by ratio" do
        expect(subject.div_times(3/2r)).to eq [ 6/6r, 9/4r ]
      end
    end

    describe "#plus_minus" do
      it "returns the result of ratio subtracted/added to self" do
        expect(subject.plus_minus(5/4r)).to eq [ 2/8r, 22/8r ]
      end
    end

    describe "#cent_diff" do
      it "returns the cent difference between self and given ratio" do
        expect(subject.cent_diff(5/4r)).to eq 315.65
      end
    end
  end

  describe "comparison" do
    let(:arg1) { 3/2r }
    let(:arg2) { nil }

    it "works as expected" do
      expect(subject == subject).to be true
      expect(subject < subject).to be false
      expect(subject > subject).to be false
      expect(subject >= subject).to be true
      expect(subject <= subject).to be true
    end
  end

  describe "operators" do
    let(:arg1) { 3/2r }
    let(:arg2) { nil }

    describe "#+" do
      it "returns the ratio sum" do
        expect(subject + subject).to eq described_class.new(12,4)
      end
    end

    describe "#-" do
      it "returns the ratio difference" do
        expect(subject - subject).to eq described_class.new(0,4)
      end
    end

    describe "#*" do
      it "returns the ratio product" do
        expect(subject * subject).to eq described_class.new(9,4)
      end
    end

    describe "#/" do
      it "returns the ratio quotient" do
        expect(subject / subject).to eq described_class.new(6,6)
      end
    end

    describe "#**" do
      it "returns the ratio raised to the power" do
        expect(subject ** 3).to eq described_class.new(27,8)
      end
    end

    describe "#mediant_sum" do
      it "returns the Farey sum" do
        expect(subject.mediant_sum(subject)).to eq described_class.new(6,4)
      end
    end
  end

  describe "#ratio" do
    let(:arg1) { 3/2r }
    let(:arg2) { nil }

    it "returns itself" do
      expect(self).to eq self
    end
  end

  describe "#lcm" do
    let(:arg1) { 3/2r }
    let(:arg2) { nil }

    it "returns the least common multiple between the denominators of self and another ratios" do
      expect(subject.lcm(5/4r)).to eq 4
    end
  end

  describe "#label" do
    let(:arg2) { nil }

    context "with numerator less than 7 digits long" do
      let(:arg1) { 3/2r }

      it "returns the ratio" do
        expect(subject.label).to eq "3/2"
      end
    end

    context "with numerator greater than 7 digits long" do
      let(:arg1) { 2**(1.0/12) }

      it "does something" do
        expect(subject.label).to eq "1.06"
      end
    end

    context "with a provided label" do
      let(:arg1) { 2**(1.0/12) }
      let(:label) { "2^(1/12)" }

      it "returns the provided label" do
        expect(described_class.new(arg1, arg2, label: label).label).to eq label
      end
    end
  end
end
