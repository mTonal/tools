require "spec_helper"

RSpec.describe Tonal::Ratio::Approximation do
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
      let(:ratio) { Tonal::Ratio.new(3/2r) }

      it "returns the neighbors distance away from ratio's antecedent and consequent" do
        expect(described_class.neighbors(vacinity: ratio, away: 2)).to eq [Tonal::Ratio.new(3,2), Tonal::Ratio.new(5,2), Tonal::Ratio.new(1,2), Tonal::Ratio.new(3,4), Tonal::Ratio.new(3,0), Tonal::Ratio.new(5,4), Tonal::Ratio.new(5,0), Tonal::Ratio.new(1,4), Tonal::Ratio.new(1,0)]
      end
    end
  end

  describe "instance methods" do
    let(:ratio) { Tonal::Ratio.new(3/2r) }

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
          expect(ratio.approximate.by_continued_fraction.length).to be <= Tonal::Ratio::Approximation::CONVERGENT_LIMIT
        end

        it "returns ratios that are within 5 cents of self" do
          expect(ratio.approximate.by_continued_fraction.all?{|r| r.cent_diff(ratio) <= Tonal::Cents::TOLERANCE}).to be true
        end

        it "returns ratios with maximum primes limited only by the depth of the search" do
          expect(ratio.approximate.by_continued_fraction.all?{|r| r.max_prime <= 2549 }).to be true
        end
      end
    end

    describe "#by_quotient_walk" do
      let(:ratio) { Tonal::Ratio.ed(12,1) }
      let(:max_prime) { 89 }

      it "returns ratios with max prime" do
        expect(ratio.approximate.by_quotient_walk(max_prime: max_prime).entries).to eq [(17/16r), (18/17r), (35/33r), (53/50r), (71/67r), (89/84r), (196/185r)]
      end
    end

    describe "#by_tree_path" do
      let(:ratio) { Tonal::Ratio.ed(12,1) }
      let(:depth) { 10 }

      it "returns 10 ratios" do
        expect(ratio.approximate.by_tree_path(depth: depth).count).to eq depth
      end
    end

    describe "#by_superparticular" do
      let(:ratio) { Tonal::Ratio.new(3/2r)}
      let(:depth) { 5 }

      it "returns approximations by descending superparticulars factored by ratio" do
        expect(ratio.approximate.by_superparticular(depth: depth).entries).to eq [(1041/692r), (1044/694r), (1047/696r), (1050/698r), (1053/700r)]
      end

      context "when the superpart is the denomimator" do
        it "returns approximations by ascending superparticulars factored by ratio" do
          expect(ratio.approximate.by_superparticular(superpart: :lower, depth: depth).entries).to eq [(346/347r), (347/348r), (348/349r), (349/350r), (350/351r)].map{|r| r * 3/2r}
        end
      end
    end

    describe "#by_neighborhood" do
      let(:ratio) { Tonal::Ratio.new(3,2) }

      context "with arguments" do
        let(:cents_tolerance) { 5 }
        let(:max_prime) { 23 }
        let(:max_boundary) { 10 }
        let(:max_scale) { 60 }
        let(:ratios) { ratio.approximate.by_neighborhood(max_prime: max_prime, max_boundary: max_boundary, max_scale: max_scale) }
        let(:ratio_in_cents) { ratio.to_cents }

        it "returns a set of ratios within 5¢ of ratio and with max prime of 23" do
          expect(ratios.entries).to eq [(175/117r), (176/117r)]
          expect(ratios.all?{|r| Tonal::Ratio.within_cents?(r.to_cents, ratio_in_cents, cents_tolerance)}).to be true
          expect(ratios.all?{|r| r.within_prime?(max_prime) }).to be true
        end
      end
    end
  end
end

RSpec.describe Tonal::Ratio::Approximation::Set do
  describe "#sort_by" do
    let(:ratio) { Tonal::ReducedRatio.new(2**(6.0/19)) }
    let(:ratio_of_interest) { 61/49r }
    # The approximation set is:
    # (5605597082100993/4503599627370496): [(5/4), (56/45), (61/49), (117/94), (1114/895), (9029/7254), (28201/22657), (2406114/1933099), (2434315/1955756)]
    let(:approximation_set) { ratio.approximate.by_continued_fraction(cents_tolerance: 10) }

    context "with to_f" do
      it "sorts by floating point value" do
        expect(approximation_set.sort_by(&:to_f).find_index(ratio_of_interest)).to eq 7
      end
    end

    context "with benedetti_height" do
      it "sorts by the Benedetti height" do
        expect(approximation_set.sort_by(&:benedetti_height).find_index(ratio_of_interest)).to eq 2
      end
    end

    context "with max_prime" do
      it "sorts by the maximum prime" do
        expect(approximation_set.sort_by(&:max_prime).find_index(ratio_of_interest)).to eq 3
      end
    end

    context "with min_prime" do
      it "sorts by the minimum prime" do
        expect(approximation_set.sort_by(&:min_prime).find_index(ratio_of_interest)).to eq 7
      end
    end

    context "with wilson_height" do
      it "sorts by the Wilson height" do
        expect(approximation_set.sort_by(&:wilson_height).find_index(ratio_of_interest)).to eq 3
      end
    end
  end
end