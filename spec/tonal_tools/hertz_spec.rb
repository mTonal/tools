require "spec_helper"

RSpec.describe Tonal::Hertz do
  let(:number) { 400 }

  describe ".reference" do
    it "returns 440 Hz" do
      expect(described_class.reference).to eq described_class.new(440.0)
    end
  end

  describe "comparison" do
    let(:hertz) { described_class.new(number) }

    context "when number is less" do
      let(:other_hertz) { described_class.new(500) }

      it "returns true" do
        expect(hertz).to be < other_hertz
      end
    end

    context "when number is greater" do
      let(:other_hertz) { described_class.new(300) }

      it "returns true" do
        expect(hertz).to be > other_hertz
      end
    end

    context "when number is equal" do
      let(:other_hertz) { described_class.new(400) }

      it "returns true" do
        expect(hertz).to eq other_hertz
      end
    end
  end

  describe "#to_cents" do
    let(:hertz) { described_class.new(number) }

    it "returns the cents difference from the default reference frequency, 440 Hz" do
      expect(hertz.to_cents).to eq -165.0
    end

    context "with a custom reference frequency" do
      let(:reference) { described_class.new(200) }

      it "returns the cents difference from the custom reference frequency" do
        expect(hertz.to_cents(reference: reference)).to eq 1200.0
      end
    end
  end

  describe "#value" do
    it "returns the value that was input" do
      expect(described_class.new(number).value).to eq 400
    end
  end

  describe "#to_r" do
    it "returns the value as a Rational" do
      expect(described_class.new(number).to_r).to eq 400/1r
    end
  end

  describe "#to_f" do
    it "returns the values as a Float" do
      expect(described_class.new(number).to_f).to eq 400.0
    end
  end
end
