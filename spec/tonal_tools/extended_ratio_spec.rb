require "spec_helper"

RSpec.describe Tonal::ExtendedRatio do
  describe "initialization" do
    it "raises an error if partials and ratios are provided" do
      expect { described_class.new(partials: [4], ratios: [1/1r]) }.to raise_error(ArgumentError, "Provide either partials or ratios, not both")
    end

    it "raises an error if neither partials nor ratios are provided" do
      expect { described_class.new }.to raise_error(ArgumentError, "Provide either partials or ratios")
    end

    it "initializes correctly with partials" do
      er = described_class.new(partials: [4, 5, 6])
      expect(er.inspect).to eq "4:5:6"
    end

    it "initializes correctly with ratios" do
      er = described_class.new(ratios: [1/1r, 5/4r, 3/2r])
      expect(er.inspect).to eq "4:5:6"
    end

    context "with partials expressed as Rationals" do
      it "initializes correctly" do
        er = described_class.new(partials: [4/1r, 5/1r, 6/1r])
        expect(er.inspect).to eq "4:5:6"
      end
    end

    context "with partials expressed as a Range" do
      it "initializes correctly" do
        er = described_class.new(partials: (4..7))
        expect(er.inspect).to eq "4:5:6:7"
      end
    end
  end

  describe "#partials" do
    it "returns the partials of the extended ratio in ascending order" do
      er = described_class.new(partials: [105, 60, 70, 84])
      expect(er.partials).to eq([60, 70, 84, 105])
    end
  end

  describe "#ratios" do
    it "returns the ratios from the first note" do
      er = described_class.new(partials: [4, 5, 6])
      expect(er.ratios).to eq([1/1r, 5/4r, 3/2r])
    end
  end

  describe "expressing sub-harmonic ratios" do
    it "returns the correct sub-harmonic ratios for the ERF partials representing them" do
      er = described_class.new(partials: [60, 70, 84, 105])
      expect(er.partials).to eq([60, 70, 84, 105])
      expect(er.ratios).to eq([1/1r, 7/6r, 7/5r, 7/4r])
    end
  end

  describe "#interval_between" do
    it "returns the interval between two partials" do
      er = described_class.new(partials: [4, 5, 6])
      expect(er.interval_between(0,2).ratio).to eq(3/2r)
    end

    it "returns nil if the index is not within the number of partials" do
      er = described_class.new(partials: [4, 5])
      expect(er.interval_between(0,2)).to be_nil
    end
  end

  describe "#to_subharmonic_extended_ratio" do
    it "converts the extended ratio to its sub-harmonic equivalent" do
      er = described_class.new(partials: [4, 5, 6])
      ser = er.to_subharmonic_extended_ratio
      expect(ser).to be_a(Tonal::SubharmonicExtendedRatio)
      expect(ser.partials).to eq([1/15r, 1/12r, 1/10r])
      expect(er.ratios).to eq ser.ratios
    end
  end
end

describe Tonal::SubharmonicExtendedRatio do
  describe "initialization" do
    it "raises an error if partials and ratios are provided" do
      expect { described_class.new(partials: [1/4r], ratios: [1/1r]) }.to raise_error(ArgumentError, "Provide either partials or ratios, not both")
    end

    it "raises an error if neither partials nor ratios are provided" do
      expect { described_class.new }.to raise_error(ArgumentError, "Provide either partials or ratios")
    end

    it "initializes correctly with partials" do
      ser = described_class.new(partials: [1/4r, 1/5r, 1/6r])
      expect(ser.inspect).to eq "6:5:4"
    end

    it "initializes correctly with ratios" do
      ser = described_class.new(ratios: [1/1r, 5/4r, 3/2r])
      expect(ser.inspect).to eq "15:12:10"
    end
  end

  describe "#partials" do
    it "returns the partials as reciprocal ratios in ascending order" do
      ser = described_class.new(partials: [4, 5, 6, 7])
      expect(ser.partials).to eq([1/7r, 1/6r, 1/5r, 1/4r])
    end
  end

  describe "#ratios" do
    it "returns the sub-harmonic ratios" do
      ser = described_class.new(partials: [4, 5, 6, 7])
      expect(ser.ratios).to eq([1/1r, 7/6r, 7/5r, 7/4r])
    end
  end

  describe "expressing harmonic ratios" do
    it "returns the correct harmonic ratios for the SEFR partials representing them" do
      ser = described_class.new(partials: [105, 84, 70, 60])
      expect(ser.partials).to eq([1/105r, 1/84r, 1/70r, 1/60r])
      expect(ser.ratios).to eq([1/1r, 5/4r, 3/2r, 7/4r])
    end
  end

  describe "#interval_between" do
    it "returns the interval between two partials" do
      ser = described_class.new(partials: [105, 84, 70, 60])
      expect(ser.interval_between(0,2).ratio).to eq(3/2r)
    end
  end

  describe "#to_extended_ratio" do
    it "converts the sub-harmonic extended ratio to its harmonic equivalent" do
      ser = described_class.new(partials: [105, 84, 70, 60])
      er = ser.to_extended_ratio
      expect(er).to be_a(Tonal::ExtendedRatio)
      expect(er.partials).to eq [4, 5, 6, 7]
      expect(er.ratios).to eq ser.ratios
    end
  end
end
