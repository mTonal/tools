require "spec_helper"

RSpec.describe Tonal::Interval do
  describe "initialization" do
    context "with two args" do
      context "with arrays" do
        let(:arg1) { [3, 2] }
        let(:arg2) { [4, 3] }

        it "accepts them" do
          interval = described_class.new(arg1, arg2)
          expect(interval.upper_ratio).to eq Tonal::Ratio.new(3, 2)
          expect(interval.lower_ratio).to eq Tonal::Ratio.new(4, 3)
        end
      end

      let(:upper_ratio) { [7/4r, Tonal::ReducedRatio.new(7,4), Tonal::Ratio.new(7, 1)].sample }
      let(:lower_ratio) { [3/2r, Tonal::ReducedRatio.new(3,2), Tonal::Ratio.new(3, 1)].sample }

      it "accepts a Rational, Tonal::Ratio or Tonal::ReducedRatio as upper and lower ratios" do
        expect(described_class.new(upper_ratio, lower_ratio)).to be_a_kind_of(Tonal::Interval)
      end

      describe "order of inputs" do
        context "when upper ratio is greater than the lower ratio" do
          let(:upper_ratio) { 7/4r }
          let(:lower_ratio) { 5/4r }

          it "returns the intervalic ratio between the upper ratio and the lower ratio" do
            expect(described_class.new(upper_ratio, lower_ratio).intervalic_ratio).to eq 7/5r
          end
        end

        context "when lower ratio is greater than the upper ratio" do
          let(:upper_ratio) { 5/4r }
          let(:lower_ratio) { 7/4r }

          it "returns the intervalic ratio between the upper and lower ratio" do
            expect(described_class.new(upper_ratio, lower_ratio).intervalic_ratio).to eq 10/7r
          end
        end
      end
    end

    context "with one arg" do
      let(:arg1) { 3 }
      it "takes arg1 as the upper ratio and 1/1 as the lower ratio" do
        interval = described_class.new(arg1)
        expect(interval.upper_ratio).to eq 3/2r
        expect(interval.lower_ratio).to eq 1/1r
      end
    end

    context "with four args" do
      let(:arg1) { 2 }
      let(:arg2) { 3 }
      let(:arg3) { 5 }
      let(:arg4) { 7 }

      it "takes arg1 and arg2 as the numerator and denominator of the lower ratio and arg3 and arg4 as the numerator and denominator of the upper ratio" do
        interval = described_class.new(arg1, arg2, arg3, arg4)
        expect(interval.upper_ratio).to eq 4/3r
        expect(interval.lower_ratio).to eq 10/7r
      end
    end

    context "with number of args not 1, 2, or 4" do
      it "raises an error" do
        expect { described_class.new(1, 2, 3, 4, 5) }.to raise_error(ArgumentError, "One, two or four arguments required. Either one ratio (the other defaulting to 1/1), two ratios, or two pairs of numerator, denominator")
      end
    end

    context "with irrational numbers" do
      let(:arg1) { Math.sqrt(2) }
      let(:arg2) { Math.sqrt(3) }
      it "displays in compact format" do
        expect(described_class.new(arg2, arg1).inspect).to eq "#{(arg2/arg1).round(2)} (#{arg2.round(2)} / #{arg1.round(2)})"
      end
    end

    describe "reduced:" do
      let(:arg1) { 10 }
      let(:arg2) { 5 }
      let(:arg3) { 3 }
      let(:arg4) { 15 }

      context "when true" do
        let(:reduced) { true }

        it "treats the ratios as reduced" do
          interval = described_class.new(arg1, arg2, arg3, arg4, reduced: reduced)
          expect(interval.upper_ratio).to eq 1/1r
          expect(interval.lower_ratio).to eq 8/5r
        end
      end

      context "when false" do
        let(:reduced) { false }

        it "treats the ratios as unreduced" do
          interval = described_class.new(arg1, arg2, arg3, arg4, reduced: reduced)
          expect(interval.upper_ratio).to eq 10/5r
          expect(interval.lower_ratio).to eq 3/15r
        end
      end
    end
  end

  describe "#lower_ratio, #upper_ratio and #intervalic_ratio" do
    let(:upper_ratio) { 7/4r }
    let(:lower_ratio) { 3/2r }
    it "returns the upper and lower ratios" do
      interval = described_class.new(upper_ratio, lower_ratio)
      expect(interval.upper_ratio).to eq upper_ratio
      expect(interval.lower_ratio).to eq lower_ratio
      expect(interval.intervalic_ratio).to eq 7/6r
    end
  end

  describe "methods" do
    let(:upper_ratio) { 7/4r }
    let(:lower_ratio) { 3/2r }

    describe "#numerator and #denominator" do
      it "returns the numerator and denominator of the intervalic ratio" do
        interval = described_class.new(upper_ratio, lower_ratio)
        intervalic_ratio = interval.intervalic_ratio
        expect(intervalic_ratio).to eq 7/6r
        expect(interval.numerator).to eq 7
        expect(interval.denominator).to eq 6
      end
    end

    describe "#to_r" do
      let(:upper_ratio) { 35/18r }
      let(:lower_ratio) { 27/16r }

      it "returns the intervalic ratio as a Rational" do
        interval = described_class.new(upper_ratio, lower_ratio)
        expect(interval.to_r).to be_a_kind_of(Rational)
        expect(interval.to_r).to eq 280/243r
      end
    end

    describe "#to_a" do
      it "returns the interval endpoints in an array" do
        expect(described_class.new(upper_ratio, lower_ratio).to_a).to eq [7/4r, 3/2r]
      end
    end

    describe "#denominize" do
      let(:upper_ratio) { 7/4r }
      let(:lower_ratio) { 3/2r }

      it "returns the interval endpoints with their denominators equalized" do
        expect(described_class.new(upper_ratio, lower_ratio).denominize).to eq [7/4r, 6/4r]
      end
    end

    describe "#approximate" do
      let(:arg) { 2.edo(12) }

      it "returns the intervalic ratio approximated by the continued fraction method within a cents tolerance" do
        expect(described_class.new(arg).approximate.intervalic_ratio).to eq 9/8r
      end
    end

    describe "#root_interval" do
      let(:upper_ratio) { 9/8r }
      let(:lower_ratio) { 1/1r }
      it "returns the intervalic ratio's square root by default" do
        expect(described_class.new(upper_ratio, lower_ratio).root_interval.intervalic_ratio).to eq (9/8r).power(1,2)
      end

      context "with power: and root:" do
        let(:power) { 2 }
        let(:root) { 3 }
        it "returns the intervalic ratio raised to the power of the root" do
          expect(described_class.new(upper_ratio, lower_ratio).root_interval(power: power, root: root).intervalic_ratio).to eq (9/8r).power(2,3)
        end
      end

      context "with approximant" do
        it "returns the intervalic ratio's square root approximated by the continued fraction method within a cents tolerance" do
          expect(described_class.new(upper_ratio, lower_ratio).root_interval(approximant: 0).intervalic_ratio).to eq 17/16r
        end
      end

      context "with from: :upper_ratio" do
        it "returns the interval calculated from the upper ratio" do
          expected_value = ((9/8r) / (9/8r).power(1,2))
          expect(described_class.new(upper_ratio, lower_ratio).root_interval(from: :upper_ratio).intervalic_ratio.to_f).to eq expected_value
        end
      end

      context "with nonsense in from:" do
        it "defaults to :lower_ratio" do
          expected_value = 17/16r
          expect(described_class.new(upper_ratio, lower_ratio).root_interval(approximant: 0, from: :nonsense).intervalic_ratio).to eq expected_value
        end
      end
    end

    describe "#inspect" do
      context "with rational ratios" do
        let(:upper_ratio) { 3/2r }
        let(:lower_ratio) { 5/4r }

        it "returns a string representation of the interval with ratios in rational format" do
          interval = described_class.new(upper_ratio, lower_ratio)
          expect(interval.inspect).to eq "6/5 (3/2 / 5/4)"
        end
      end

      context "with irrational ratios" do
        let(:upper_ratio) { Math.sqrt(3) }
        let(:lower_ratio) { Math.sqrt(2) }

        it "returns a string representation of the interval with ratios in decimal format" do
          interval = described_class.new(upper_ratio, lower_ratio)
          expect(interval.inspect).to eq "1.22 (1.73 / 1.41)"
        end
      end
    end
  end
end
