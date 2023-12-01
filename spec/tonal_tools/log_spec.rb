require "spec_helper"

RSpec.describe Tonal::Log do
  let(:base) { 2 }
  let(:logarithmand) { 3/2r }
  let(:logarithm) { Math.log2(3/2r) }

  subject { described_class.new(logarithmand: logarithmand, logarithm: logarithm, base: base) }

  describe "initialization" do
    context "logarithmand, logarithm and base are provided" do
      context "base is aligned" do
        it "all arguments are accepted without change" do
          expect(subject.base).to eq base
          expect(subject.logarithmand).to eq logarithmand
          expect(subject.logarithm).to eq logarithm
        end
      end

      context "base is not aligned" do
        let(:base) { 3 }

        it "base is changed to align with provided logarithmand and logarithm" do
          expect{subject}.to output("Provided base (3) does not align with logarithmand and logarithm. Using calculated base (2.0) instead\n").to_stdout
          expect(subject.base).to eq 2
          expect(subject.logarithmand).to eq logarithmand
          expect(subject.logarithm).to eq logarithm
        end
      end
    end

    context "logarithmand and logarithm are provided, but base is not" do
      let(:base) { nil }

      it "base is derived" do
        expect(subject.base).to eq 2.0
      end
    end

    context "logarithmand and base are provided, but logarithm is not" do
      let(:logarithm) { nil }

      it "logarithm is derived" do
        expect(subject.logarithm).to eq Math.log2(3/2r)
      end
    end

    context "logarithm and base are provided, but logarithmand is not" do
      let(:logarithmand) { nil }

      it "logarithmand is derived" do
        expect(subject.logarithmand).to eq 1.5
      end
    end

    context "only logarithmand is provided" do
      let(:logarithm) { nil }
      let(:base) { nil }

      it "natural log is used to derive the logarithm" do
        expect(subject.base).to eq Math::E
        expect(subject.logarithm).to eq 0.4054651081081644
        expect(subject.logarithmand).to eq 1.5
      end
    end

    context "only logarithm is provided" do
      let(:logarithmand) { nil }
      let(:base) { nil }

      it "natural log is used to derive the logarithmand" do
        expect(subject.base).to eq Math::E
        expect(subject.logarithm).to eq Math.log2(3/2r)
        expect(subject.logarithmand).to eq 1.794923676034446
      end
    end

    context "no arguments are provided" do
      it "raises an exception" do
        expect{ described_class.new }.to raise_error(ArgumentError, "logarithmand or logarithm must be provided")
      end
    end

    context "only base is provided" do
      it "raises an exception" do
        expect{ described_class.new(base: base) }.to raise_error(ArgumentError, "logarithmand or logarithm must be provided")
      end
    end
  end
end
