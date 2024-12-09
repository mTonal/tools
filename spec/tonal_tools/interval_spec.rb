require "spec_helper"

RSpec.describe Tonal::Interval do
  describe "initialization" do
    context "with two args" do
      context "with arrays" do
        let(:arg1) { [3, 2] }
        let(:arg2) { [4, 3] }

        it "accepts them" do
          expect(described_class.new(arg1, arg2).lower).to eq Ratio[3, 2]
          expect(described_class.new(arg1, arg2).upper).to eq Ratio[4, 3]
        end
      end

      let(:lower_ratio) { [3/2r, ReducedRatio[3,2], Ratio[3, 1]].sample }
      let(:upper_ratio) { [7/4r, ReducedRatio[7,4], Ratio[7, 1]].sample }

      it "accepts a Rational, Tonal::Ratio or Tonal::ReducedRatio as upper and lower ratios" do
        expect(described_class.new(upper_ratio, lower_ratio)).to be_a_kind_of(Tonal::Interval)
      end

      describe "order of inputs" do
        context "when upper ratio is greater than the lower ratio" do
          let(:upper_ratio) { 7/4r }
          let(:lower_ratio) { 5/4r }

          it "returns the interval between the upper ratio and the lower ratio" do
            expect(described_class.new(lower_ratio, upper_ratio).interval).to eq 7/5r
          end
        end

        context "when lower ratio is greater than the upper ratio" do
          let(:upper_ratio) { 5/4r }
          let(:lower_ratio) { 7/4r }

          it "returns the interval between the lower ratio and the upper ratio" do
            expect(described_class.new(lower_ratio, upper_ratio).interval).to eq 10/7r
          end
        end
      end
    end

    context "with four args" do
      let(:arg1) { 2 }
      let(:arg2) { 3 }
      let(:arg3) { 5 }
      let(:arg4) { 7 }

      it "takes arg1 and arg2 as the numerator and denominator of the lower ratio and arg3 and arg4 as the numerator and denominator of the upper ratio" do
        expect(described_class.new(arg1, arg2, arg3, arg4).lower).to eq 4/3r
        expect(described_class.new(arg1, arg2, arg3, arg4).upper).to eq 10/7r
      end
    end

    describe "the reduced arg" do
      let(:arg1) { 10 }
      let(:arg2) { 5 }
      let(:arg3) { 15 }
      let(:arg4) { 3 }

      context "when true" do
        let(:reduced) { true }

        it "treats the ratios as reduced" do
          expect(described_class.new(arg1, arg2, arg3, arg4, reduced: reduced).lower).to eq 1/1r
          expect(described_class.new(arg1, arg2, arg3, arg4, reduced: reduced).upper).to eq 5/4r
        end
      end

      context "when false" do
        let(:reduced) { false }

        it "treats the ratios as unreduced" do
          expect(described_class.new(arg1, arg2, arg3, arg4, reduced: reduced).lower).to eq 10/5r
          expect(described_class.new(arg1, arg2, arg3, arg4, reduced: reduced).upper).to eq 15/3r
        end
      end
    end
  end

  describe "attributes" do
    let(:upper_ratio) { 3/2r }
    let(:lower_ratio) { 7/4r }

    describe "#numerator/#denominator" do
      it "returns the numerator and denominator of the interval" do
        expect(described_class.new(lower_ratio, upper_ratio).numerator).to eq 12
        expect(described_class.new(lower_ratio, upper_ratio).denominator).to eq 7
      end
    end

    describe "ratios" do
      it "returns the upper and lower ratios" do
        expect(described_class.new(lower_ratio, upper_ratio).lower).to eq 7/4r
        expect(described_class.new(lower_ratio, upper_ratio).upper).to eq 3/2r
      end
    end
  end

  describe "#denominize" do
    let(:upper_ratio) { 3/2r }
    let(:lower_ratio) { 7/4r }

    it "returns the interval endpoints with their denominators equalized" do
      expect(described_class.new(lower_ratio, upper_ratio).denominize).to eq [7/4r, 6/4r]
    end
  end

  describe "#ratio" do
    context "with Rationals" do
      let(:upper_ratio) { 3/2r }
      let(:lower_ratio) { 7/4r }

      it "returns the interval as a Tonal::ReducedRatio" do
        expect(described_class.new(lower_ratio, upper_ratio).ratio).to be_a_kind_of(Tonal::Ratio)
        expect(described_class.new(lower_ratio, upper_ratio).ratio).to eq 12/7r
      end

      describe "#to_r" do
        let(:upper_ratio) { 27/16r }
        let(:lower_ratio) { 35/18r }

        it "returns the interval ratio as a Rational" do
          expect(described_class.new(lower_ratio, upper_ratio).to_r).to be_a_kind_of(Rational)
          expect(described_class.new(lower_ratio, upper_ratio).to_r).to eq 243/140r
        end
      end

      describe "#to_a" do
        let(:upper_ratio) { 3/2r }
        let(:lower_ratio) { 7/4r }

        it "returns the interval endpoints in an array" do
          expect(described_class.new(lower_ratio, upper_ratio).to_a).to eq [7/4r, 3/2r]
        end
      end

      describe "attributes" do
        let(:upper_ratio) { 3/2r }
        let(:lower_ratio) { 7/4r }

        describe "#interval" do
          it "returns the interval calculated from upper and lower ratios" do
            expect(described_class.new(lower_ratio, upper_ratio).interval).to eq 12/7r
          end
        end
      end
    end
  end
end
