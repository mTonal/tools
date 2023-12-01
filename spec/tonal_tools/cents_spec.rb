require "spec_helper"

RSpec.describe Tonal::Cents do
  let(:cent_scale) { described_class::CENT_SCALE }
  let(:ratio) { 3/2r }
  let(:log) { Math.log2(3/2r) }
  let(:cents) { Math.log2(3/2r) * cent_scale }

  subject { described_class.new(cents: cents, log: log, ratio: ratio) }

  describe "initialization" do
    context "no argument provided" do
      let(:ratio) { nil }
      let(:log) { nil }
      let(:cents) { nil }

      it "raises an exception" do
        expect{ subject }.to raise_error(ArgumentError, "One of cents:, log: or ratio: must be provided")
      end
    end

    context "more than one argument provided" do
      it "raises and exception" do
        expect{ subject }.to raise_error(ArgumentError, "One of cents:, log: or ratio: must be provided")
      end
    end

    context "only cents is provided" do
      let(:ratio) { nil }
      let(:log) { nil }

      it "returns the cents" do
        expect(subject.cents).to eq 701.96
      end

      it "returns the ratio" do
        expect(subject.ratio).to eq 3/2r
      end

      it "returns the log" do
        expect(subject.log).to eq 0.5849625007211562
      end
    end

    context "only log is provided" do
      let(:ratio) { nil }
      let(:cents) { nil }

      it "returns the ratio" do
        expect(subject.ratio).to eq 3/2r
      end

      it "returns the cents" do
        expect(subject.cents).to eq 701.96
      end

      it "returns the log" do
        expect(subject.log).to eq log
      end
    end

    context "only ratio is provided" do
      let(:cents) { nil }
      let(:log) { nil }


      it "returns the ratio" do
        expect(subject.ratio).to eq 3/2r
      end

      it "returns the cents" do
        expect(subject.cents).to eq 701.96
      end

      it "returns the log" do
        expect(subject.log).to eq 0.5849625007211562
      end
    end
  end

  describe "comparison" do
    it "just works" do
      expect(described_class.new(log: Tonal::Log2.new(logarithmand: 3/2r))  < described_class.new(log: Tonal::Log2.new(logarithmand: 5/4r))).to be false
      expect(described_class.new(log: Tonal::Log2.new(logarithmand: 3/2r))  > described_class.new(log: Tonal::Log2.new(logarithmand: 5/4r))).to be true
      expect(described_class.new(log: Tonal::Log2.new(logarithmand: 3/2r))  < described_class.new(log: Tonal::Log2.new(logarithmand: 7/4r))).to be true
      expect(described_class.new(log: Tonal::Log2.new(logarithmand: 3/2r)) <= described_class.new(log: Tonal::Log2.new(logarithmand: 3/2r))).to be true
      expect(described_class.new(log: Tonal::Log2.new(logarithmand: 3/2r)) == described_class.new(log: Tonal::Log2.new(logarithmand: 3/2r))).to be true
    end
  end

  describe "methods" do
    let(:cents) { 701.9550008653874 }

    describe "#nearest_hundredth" do
      it "returns the nearest 100th cent value" do
        expect(described_class.new(cents: cents).nearest_hundredth).to eq 700.0
      end
    end

    describe "#nearest_hundredth_difference" do
      it "returns the nearest 100th cent difference" do
        expect(described_class.new(cents: cents).nearest_hundredth_difference).to eq 1.96
      end
    end

    describe "#plus_minus" do
      it "returns the cents plus-minus from self, defaulting to 5 cents" do
        expect(described_class.new(cents: cents).plus_minus).to eq [696.96, 706.96]
      end
    end
  end
end
