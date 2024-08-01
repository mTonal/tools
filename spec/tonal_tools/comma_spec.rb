require "spec_helper"

RSpec.describe Tonal::Comma do
  describe "class methods" do
    context "when comma is in repo" do
      it "returns its value" do
        expect(described_class.syntonic).to eq 81/80r
      end
    end

    context "when comma is not in repo" do
      it "returns 0" do
        expect(described_class.bogus).to eq 0/1r
      end
    end

    describe ".values" do
      it "returns values from the repo" do
        expect(described_class.values).to start_with(2048/2025r)
      end
    end

    describe ".keys" do
      it "returns keys from the repo" do
        expect(described_class.keys).to start_with("diaschisma")
      end
    end
  end
end
