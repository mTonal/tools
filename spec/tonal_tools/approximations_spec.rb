require "spec_helper"

RSpec.describe Tonal::Ratio::Approximations do
  let(:ratio) { Tonal::Ratio.new(3/2r) }

  describe "class methods" do
    describe ".new" do
      it "requires a ratio" do
        expect{ described_class.new }.to raise_error(ArgumentError, "missing keyword: :ratio")
      end

      it "requires ratio to be a Tonal::Ratio" do
        expect{ described_class.new(ratio: 1/1r) }.to raise_error(ArgumentError, "Tonal::Ratio required")
      end
    end

    describe ".neighbors" do
      it "returns the neighbors distance away from self's antecedent and consequent" do
        expect(described_class.neighbors(vacinity: ratio, away: 2)).to eq [Tonal::Ratio.new(3,2), Tonal::Ratio.new(5,2), Tonal::Ratio.new(1,2), Tonal::Ratio.new(3,4), Tonal::Ratio.new(3,0), Tonal::Ratio.new(5,4), Tonal::Ratio.new(5,0), Tonal::Ratio.new(1,4), Tonal::Ratio.new(1,0)]
      end
    end
  end

  describe "instance methods" do
    subject { described_class.new(ratio: ratio) }

    describe "#neighborhood" do
      it "returns the set of bounding ratios in the ratio grid vacinity of antecedent/consequent scaled by scale" do
        expect(subject.neighborhood(scale: 256)).to eq [Tonal::Ratio.new(767,513), Tonal::Ratio.new(768,513), Tonal::Ratio.new(767,512), Tonal::Ratio.new(769,513), Tonal::Ratio.new(768,512), Tonal::Ratio.new(767,511), Tonal::Ratio.new(769,512), Tonal::Ratio.new(768,511), Tonal::Ratio.new(769,511)]
      end
    end

    describe "#by_continued_fraction" do
      let(:ratio) { Tonal::Ratio.ed(12,1) }

      context "with defaults" do
        it "returns ratios up to the default depth" do
          expect(ratio.approx.by_continued_fraction.length).to be <= Tonal::Ratio::Approximations::CONVERGENT_LIMIT
        end

        it "returns ratios that are within 5 cents of self" do
          expect(ratio.approx.by_continued_fraction.all?{|r| r.cent_diff(ratio) <= Tonal::Cents::TOLERANCE}).to be true
        end

        it "returns ratios with maximum primes limited only by the depth of the search" do
          expect(ratio.approx.by_continued_fraction.all?{|r| r.max_prime <= 2549 }).to be true
        end
      end
    end

    describe "#by_quotient_walk" do
      let(:ratio) { Tonal::Ratio.ed(12,1) }
      let(:max_prime) { 89 }

      it "returns ratios with max prime" do
        expect(ratio.approx.by_quotient_walk(max_prime: max_prime)).to eq [(18/17r), (196/185r), (89/84r), (71/67r), (53/50r), (35/33r), (17/16r)]
      end
    end

    describe "#by_tree_path" do
      let(:ratio) { Tonal::Ratio.ed(12,1) }
      let(:depth) { 10 }

      it "returns 10 ratios" do
        expect(ratio.approx.by_tree_path(depth: depth).count).to eq 10
      end
    end

    describe "#by_neighborhood" do
      let(:ratio) { Tonal::Ratio.new(3,2) }

      context "with arguments" do
        let(:cents_tolerance) { 5 }
        let(:max_prime) { 23 }
        let(:max_boundary) { 10 }
        let(:max_scale) { 60 }
        let(:ratios) { ratio.approx.by_neighborhood(max_prime: max_prime, max_boundary: max_boundary, max_scale: max_scale) }
        let(:ratio_in_cents) { ratio.to_cents }

        it "returns a set of ratios within 5¢ of ratio and with max prime of 23" do
          expect(ratios).to eq [(175/117r), (176/117r)]
          expect(ratios.all?{|r| Tonal::Ratio.within_cents?(r.to_cents, ratio_in_cents, cents_tolerance)}).to be true
          expect(ratios.all?{|r| r.within_prime?(max_prime) }).to be true
        end
      end
    end
  end
end
