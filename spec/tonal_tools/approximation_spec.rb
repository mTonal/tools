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

      context "with 1/1" do
        let(:ratio) { Tonal::Ratio.new(1,1) }
        it "returns approximations for 1/1" do
          expect(ratio.approximate.by_continued_fraction.entries).to eq [1/1r]
        end
      end

      context "with 2/1" do
        let(:ratio) { Tonal::Ratio.new(2,1) }
        it "returns approximations for 2/1" do
          expect(ratio.approximate.by_continued_fraction.entries).to eq [2/1r]
        end
      end

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

      context "with arguments" do
        let(:cents_tolerance) { 2 }
        let(:max_prime) { 19 }
        let(:depth) { 7 }
        let(:ratios) { ratio.approximate.by_continued_fraction(cents_tolerance: cents_tolerance, max_prime: max_prime, depth: depth) }

        it "returns ratios within 2¢ of ratio" do
          expect(ratios.all?{|r| r.cent_diff(ratio) <= cents_tolerance.cents}).to be true
        end

        it "returns ratios with maximum prime less than or equal to 19" do
          expect(ratios.all?{|r| r.max_prime <= max_prime}).to be true
        end

        it "returns no more than 7 ratios" do
          expect(ratios.length).to be <= depth
        end
      end
    end

    describe "#by_tree_path" do
      let(:ratio) { Tonal::Ratio.ed(1, 12) }
      let(:depth) { 10 }

      context "with 1/1" do
        let(:ratio) { Tonal::Ratio.new(1,1) }
        it "returns approximations for 1/1" do
          expect(ratio.approximate.by_tree_path.entries).to eq [1/1r]
        end
      end

      context "with defaults" do
        it "returns ratios up to the default depth" do
          expect(ratio.approximate.by_tree_path.length).to be <= Tonal::Ratio::Approximation::DEFAULT_TREE_PATH_DEPTH
        end

        it "returns ratios that are within 5 cents of self" do
          expect(ratio.approximate.by_tree_path.all?{|r| r.cent_diff(ratio) <= Tonal::Cents::TOLERANCE}).to be true
        end

        it "returns ratios with maximum primes limited only by the depth of the search" do
          expect(ratio.approximate.by_tree_path.all?{|r| r.max_prime <= 2549 }).to be true
        end
      end

      context "with arguments" do
        let(:cents_tolerance) { 2 }
        let(:max_prime) { 19 }
        #let(:ratios) { ratio.approximate.by_tree_path(cents_tolerance: cents_tolerance, depth: depth, max_prime: max_prime) }

        before(:context) do
          @ratios = Tonal::Ratio.ed(1, 12).approximate.by_tree_path(cents_tolerance: 2, depth: 10, max_prime: 19)
        end

        it "returns ratios within 2¢ of ratio" do
          expect(@ratios.all?{|r| r.cent_diff(ratio) <= cents_tolerance.cents}).to be true
        end

        it "returns ratios with maximum prime less than or equal to 19" do
          expect(@ratios.all?{|r| r.max_prime <= max_prime}).to be true
        end

        it "returns no more than 10 ratios" do
          expect(@ratios.length).to be <= depth
        end
      end
    end

    describe "#by_superparticular" do
      let(:ratio) { Tonal::Ratio.new(3/2r) }
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

      context "with defaults" do
        let(:ratios) { ratio.approximate.by_neighborhood }
        let(:ratio_in_cents) { ratio.to_cents }

        it "returns a set of ratios within 5¢ of ratio" do
          expect(ratios.all?{|r| r.cent_diff(ratio) <= Tonal::Cents::TOLERANCE.cents}).to be true
        end

        it "returns ratios with maximum primes limited only by the depth of the search" do
          expect(ratios.all?{|r| r.max_prime <= 2549 }).to be true
        end
      end

      context "with arguments" do
        let(:cents_tolerance) { 5 }
        let(:max_prime) { 23 }
        let(:max_boundary) { 10 }
        let(:max_scale) { 60 }
        let(:ratios) { ratio.approximate.by_neighborhood(max_prime: max_prime, max_boundary: max_boundary, max_scale: max_scale) }
        let(:ratio_in_cents) { ratio.to_cents }

        it "returns a set of ratios within 5¢ of ratio and with max prime less than 23" do
          expect((176/117r).max_prime).to eq 13
          expect((176/117r).to_cents).to be_within(5.cents).of(ratio_in_cents)
          expect(ratios).to include(176/117r)
        end
      end
    end
  end
end

RSpec.describe Tonal::Ratio::Approximation::Set do
  describe "#entries" do
    let(:ratio) { Tonal::ReducedRatio.ed(6,19) }
    let(:approximation_set) { ratio.approximate.by_continued_fraction(cents_tolerance: 10) }

    it "returns the array of ratios in the set" do
      expect(approximation_set.entries).to eq [Tonal::ReducedRatio.new(5/4r), Tonal::ReducedRatio.new(56/45r), Tonal::ReducedRatio.new(61/49r), Tonal::ReducedRatio.new(117/94r), Tonal::ReducedRatio.new(1114/895r), Tonal::ReducedRatio.new(9029/7254r), Tonal::ReducedRatio.new(28201/22657r), Tonal::ReducedRatio.new(2406114/1933099r), Tonal::ReducedRatio.new(2434315/1955756r)]
    end
  end

  describe "#sort_by" do
    let(:ratio) { Tonal::ReducedRatio.ed(6,19) }
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

  describe "#to_a" do
    let(:ratio) { Tonal::ReducedRatio.new(2**(6.0/19)) }
    let(:approximation_set) { ratio.approximate.by_continued_fraction(cents_tolerance: 10) }

    it "returns the array of ratios in the set" do
      expect(approximation_set.to_a).to eq [Tonal::ReducedRatio.new(5/4r), Tonal::ReducedRatio.new(56/45r), Tonal::ReducedRatio.new(61/49r), Tonal::ReducedRatio.new(117/94r), Tonal::ReducedRatio.new(1114/895r), Tonal::ReducedRatio.new(9029/7254r), Tonal::ReducedRatio.new(28201/22657r), Tonal::ReducedRatio.new(2406114/1933099r), Tonal::ReducedRatio.new(2434315/1955756r)]
    end
  end

  describe "#max_primes" do
    let(:ratio) { Tonal::ReducedRatio.new(2**(6.0/19)) }
    let(:approximation_set) { ratio.approximate.by_continued_fraction(cents_tolerance: 10) }

    it "returns the array of maximum primes for the ratios in the set" do
      expect(approximation_set.max_primes).to eq [5, 7, 61, 47, 557, 9029, 28201, 133673, 44449]
    end
  end

  describe "#min_primes" do
    let(:ratio) { Tonal::ReducedRatio.new(2**(6.0/19)) }
    let(:approximation_set) { ratio.approximate.by_continued_fraction(cents_tolerance: 10) }

    it "returns the array of minimum primes for the ratios in the set" do
      expect(approximation_set.min_primes).to eq [2, 2, 7, 2, 2, 2, 139, 2, 2]
    end
  end
end
