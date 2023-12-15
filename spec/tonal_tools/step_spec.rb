require "spec_helper"

RSpec.describe Tonal::Step do
  let(:modulo) { 31 }
  let(:log) { nil }
  let(:step) { nil }
  let(:ratio) { nil }

  subject { described_class.new(modulo: modulo, log: log, step: step, ratio: ratio) }

  describe "initialization" do
    context "without modulo" do
      let(:modulo) { nil }
      let(:ratio) { 3/2r }

      it "raises an exception" do
        expect{ subject }.to raise_error(ArgumentError, "modulo: required")
      end
    end

    context "without log, step or ratio" do
      it "raises an exception" do
        expect{ subject }.to raise_error(ArgumentError, "One of log:, step: or ratio: must be provided")
      end
    end

    context "with ratio" do
      let(:ratio) { 3/2r }

      it "returns the step of number for the given modulo" do
        expect(subject.step).to eq 18
      end
    end

    context "with step" do
      let(:step) { 1 }

      it "step is assigned the number" do
        expect(subject.step).to eq 1
      end

      it "returns the log of number\modulo" do
        expect(subject.log).to eq (2**(1.0/31)).log2
      end
    end

    context "with log" do
      let(:log) { Tonal::Log2.new(logarithmand: 3/2r) }

      it "returns the step of the log2 number for the given modulo" do
        expect(subject.step).to eq 18
      end
    end
  end

  describe "attributes" do
    let(:ratio) { 3/2r }
    let(:modulo) { 12 }

    it { expect(subject.ratio).to eq 3/2r }
    it { expect(subject.modulo).to eq 12 }
    it { expect(subject.step).to eq 7 }
    it { expect(subject.log).to eq 0.5849625007211562 }
    it { expect(subject.tempered).to eq 1.4983070768766815 }
  end

  describe "#convert" do
    let(:ratio) { 3/2r }
    let(:new_modulo) { 13 }

    it "creates a new Step with the number mapped on to the new modulo" do
      expect(subject.convert(new_modulo).step).to eq 8
    end
  end

  describe "#ratio" do
    let(:ratio) { 3/2r }

    it "returns the octave reduced ratio derived from 2^(step/modulo)" do
      expect(subject.ratio).to eq 3/2r
    end
  end

  describe "#to_cents" do
    let(:ratio) { 3/2r }

    it "returns self converted to cents within 100th accuracy" do
      expect(subject.to_cents).to eq 701.96
    end
  end

  describe "#+" do
    let(:increment) { 41 }
    let(:ratio) { 3/2r }

    it "increments number of steps in the given modulo" do
      expect(subject + increment).to eq described_class.new(step: (increment % subject.modulo), modulo: subject.modulo)
    end
  end

  describe "comparison" do
    let(:ratio) { 3/2r }

    context "when equal" do
      let(:other_step) { described_class.new(ratio: ratio, modulo: modulo)}

      it "regards them as equal" do
        expect(subject).to eq other_step
      end
    end

    context "when unequal" do
      let(:other_step) { described_class.new(ratio: 7/4r, modulo: modulo) }


      it "regards the other step to be greater" do
        expect(subject).to be < other_step
      end
    end
  end
end
