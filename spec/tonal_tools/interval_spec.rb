require "spec_helper"

RSpec.describe Tonal::Interval do
  describe "initialization" do
    let(:lower_ratio) { [3/2r, Tonal::ReducedRatio.new(3,2), Tonal::Ratio.new(3, 1)].sample }
    let(:upper_ratio) { [7/4r, Tonal::ReducedRatio.new(7,4), Tonal::Ratio.new(7, 1)].sample }

    it "accepts a Rational, Tonal::Ratio or Tonal::ReducedRatio as upper and lower ratios" do
      expect(described_class.new(upper_ratio, lower_ratio)).to be_a_kind_of(Tonal::Interval)
    end

    describe "order of inputs" do
      context "when upper ratio is greater than the lower ratio" do
        let(:upper_ratio) { 7/4r }
        let(:lower_ratio) { 5/4r }

        it "returns the interval between the upper ratio and the lower ratio" do
          expect(described_class.new(upper_ratio, lower_ratio).interval).to eq 7/5r
        end
      end

      context "when lower ratio is greater than the upper ratio" do
        let(:upper_ratio) { 5/4r }
        let(:lower_ratio) { 7/4r }

        it "returns the interval between the lower ratio and the upper ratio" do
          expect(described_class.new(upper_ratio, lower_ratio).interval).to eq 10/7r
        end
      end
    end
  end

  describe "attributes" do
    let(:upper_ratio) { 3/2r }
    let(:lower_ratio) { 7/4r }

    describe "#interval" do
      it "returns the interval calculated from upper and lower ratios" do
        expect(described_class.new(upper_ratio, lower_ratio).interval).to eq 12/7r
      end
    end

    describe "#numerator/#denominator" do
      it "returns the numerator and denominator of the interval" do
        expect(described_class.new(upper_ratio, lower_ratio).numerator).to eq 12
        expect(described_class.new(upper_ratio, lower_ratio).denominator).to eq 7
      end
    end

    describe "ratios" do
      it "returns the upper and lower ratios" do
        expect(described_class.new(upper_ratio, lower_ratio).lower).to eq 7/4r
        expect(described_class.new(upper_ratio, lower_ratio).upper).to eq 3/2r
      end
    end
  end

  describe "#denominize" do
    let(:upper_ratio) { 3/2r }
    let(:lower_ratio) { 7/4r }

    it "returns the interval endpoints with their denominators equalized" do
      expect(described_class.new(upper_ratio, lower_ratio).denominize).to eq [7/4r, 6/4r]
    end
  end

  describe "#ratio" do
    let(:upper_ratio) { 3/2r }
    let(:lower_ratio) { 7/4r }

    it "returns the interval as a Tonal::ReducedRatio" do
      expect(described_class.new(upper_ratio, lower_ratio).ratio).to be_a_kind_of(Tonal::ReducedRatio)
      expect(described_class.new(upper_ratio, lower_ratio).ratio).to eq 12/7r
    end
  end

  describe "#to_r" do
    let(:upper_ratio) { 27/16r }
    let(:lower_ratio) { 35/18r }

    it "returns the interval ratio as a Rational" do
      expect(described_class.new(upper_ratio, lower_ratio).to_r).to be_a_kind_of(Rational)
      expect(described_class.new(upper_ratio, lower_ratio).to_r).to eq 243/140r
    end
  end

  describe "#to_a" do
    let(:upper_ratio) { 3/2r }
    let(:lower_ratio) { 7/4r }

    it "returns the interval endpoints in an array" do
      expect(described_class.new(upper_ratio, lower_ratio).to_a).to eq [7/4r, 3/2r]
    end
  end
end
