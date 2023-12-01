require "spec_helper"

RSpec.describe Tonal::Hertz do
  let(:number) { 400 }

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
