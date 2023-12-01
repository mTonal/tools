require "spec_helper"

RSpec.describe Tonal::Log2 do
  let(:logarithmand) { 2**(1/12.0) }

  subject { described_class.new(logarithmand: logarithmand) }

  describe "constructors" do
    it "accept Numerics" do
      expect(subject.logarithm).to eq Math.log2(logarithmand)
    end

    context "with Tonal::Ratio" do
      let(:logarithmand) { Tonal::Ratio.new(3/2r) }

      it "accepts them and sets its logarithm to the arg converted by Math.log2" do
        expect(subject.logarithm).to eq Math.log2(3/2r)
      end
    end
  end

  describe "#step" do
    let(:modulo) { 12 }

    it "returns the step in a given modulo" do
      expect(subject.step(modulo)).to eq Tonal::Step.new(modulo: 12, step: 1)
    end
  end

  describe "#ratio" do
    it "returns the ratio" do
      expect(subject.ratio).to be_a(Tonal::Ratio)
      expect(subject.ratio).to eq 4771397596969315/4503599627370496r
    end
  end

  describe "#to_cents" do
    it "returns the cents" do
      expect(subject.to_cents).to be_a(Tonal::Cents)
      expect(subject.to_cents).to eq 100.0
    end
  end
end
