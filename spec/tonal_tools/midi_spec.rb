RSpec.describe Tonal::Midi::Note do
  let(:number) { 60 }

  describe "initialization" do
    context "without an argument" do
      it "creates a new Tonal::Midi::Note instance with the default value" do
        midi = described_class.new
        expect(midi.number).to eq described_class::A4_MIDI_NUMBER
      end
    end

    context "with a number argument" do
      it "creates a new Tonal::Midi::Note instance with the given value" do
        midi = described_class.new(number: number)
        expect(midi.number).to eq number
      end
    end

    context "with an invalid argument" do
      it "raises an ArgumentError" do
        expect { described_class.new(number: "invalid") }.to raise_error(ArgumentError, "Number argument is not Integer")
      end
    end

    context "initialization with frequency" do
      let(:frequency) { 440.0 }

      it "creates a new Tonal::Midi::Note instance with the given frequency" do
        midi = described_class.new(frequency: frequency)
        expect(midi.frequency.to_f).to eq frequency
        expect(midi.number).to eq 69
      end

      context "with an invalid frequency argument" do
        it "raises an ArgumentError" do
          expect { described_class.new(frequency: "invalid") }.to raise_error(ArgumentError, "Frequency argument is not Numeric or Tonal::Hertz")
        end
      end
    end
  end

  describe "#inspect" do
    it "returns a string representation of the MIDI note" do
      midi = described_class.new(number: number)
      expect(midi.inspect).to eq "#{number} MIDI"
    end
  end

  describe "#frequency" do
    it "returns the frequency corresponding to the MIDI note number" do
      midi = described_class.new(number: number)
      expect(midi.frequency.to_f).to eq 261.6255653005986
    end
  end
end