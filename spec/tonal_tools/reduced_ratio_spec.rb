require "spec_helper"

RSpec.describe Tonal::ReducedRatio do
  describe "#to_basic_ratio" do
    it "returns a copy of self as an instance of unreduced ratio" do
      expect(described_class.new(5,4).to_basic_ratio).to be_a_kind_of(Tonal::Ratio)
    end
  end

  describe "#interval_with" do
    it "returns the interval between self and the given ratio" do
      expect(described_class.new(3/2r).interval_with(7/4r)).to eq Tonal::Interval.new(3/2r, 7/4r)
    end
  end

  describe "#invert" do
    it "returns the inverted reduced ratio" do
      expect(described_class.new(3/2r).invert).to eq 4/3r
    end
  end

  describe "#invert!" do
    it "returns self inverted" do
      expect(described_class.new(3/2r).invert!).to eq 4/3r
    end
  end
end
