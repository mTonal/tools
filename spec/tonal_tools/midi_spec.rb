RSpec.describe Tonal::Midi::Note do
  let(:number) { 60 }

  describe "initialization" do
    context "without an argument" do
      it "creates a Tonal::Midi::Note instance with the default MIDI number of 69 and a frequency of 440.0 Hz" do
        expect(described_class.new.number).to eq described_class::A4_MIDI_NUMBER
        expect(described_class.new.frequency).to eq 440.0
      end
    end

    context "with a number argument" do
      it "creates a Tonal::Midi::Note instance assigned the given number and calculates the corresponding frequency" do
        expect(described_class.new(number: number).number).to eq number
        expect(described_class.new(number: number).frequency(round: 2)).to eq 261.63
      end
    end

    context "with an invalid argument" do
      it "raises an ArgumentError" do
        expect { described_class.new(number: "invalid") }.to raise_error(ArgumentError, "Number argument is not Integer")
      end
    end

    context "with frequency" do
      let(:frequency) { 220.0 }

      it "creates a Tonal::Midi::Note instance with the given frequency and MIDI number relative to A4_MIDI_NUMBER" do
        midi = described_class.new(frequency: frequency)
        expect(midi.frequency).to eq frequency
        expect(midi.number).to eq 57
      end

      context "with an invalid frequency argument" do
        it "raises an ArgumentError" do
          expect { described_class.new(frequency: "invalid") }.to raise_error(ArgumentError, "Frequency argument is not Numeric or Tonal::Hertz")
        end
      end
    end

    context "with both number and frequency" do
      it "raises an ArgumentError" do
        expect { described_class.new(number: number, frequency: 440.0) }
          .to raise_error(ArgumentError, "Provide either number: or frequency:, not both")
      end
    end

    context "with modulo" do
      let(:modulo) { 24 }

      it "creates a Tonal::Midi::Note instance with the given modulo and calculates the corresponding frequency" do
        midi = described_class.new(number: number, modulo: modulo)
        expect(midi.modulo).to eq modulo
        expect(midi.frequency(round: 2)).to eq 339.29
      end
    end

    context "with a custom reference_number and reference_frequency" do
      it "anchors the number/frequency conversion on the given reference instead of A4/440" do
        midi = described_class.new(frequency: 523.26, modulo: 31, reference_number: 60, reference_frequency: 261.63)
        expect(midi.reference_number).to eq 60
        expect(midi.reference_frequency).to eq 261.63
        expect(midi.number).to eq 91
      end

      it "defaults to A4_MIDI_NUMBER and REFERENCE_FREQUENCY" do
        midi = described_class.new(number: number)
        expect(midi.reference_number).to eq described_class::A4_MIDI_NUMBER
        expect(midi.reference_frequency).to eq Tonal::Hertz::REFERENCE_FREQUENCY
      end
    end
  end

  describe "#frequency" do
    let(:midi) { described_class.new(number: number) }

    it "returns the frequency corresponding to the MIDI note number" do
      expect(midi.frequency).to eq 261.6255653005986
    end

    context "with rounding" do
      it "returns the frequency rounded to the specified number of decimal places" do
        expect(midi.frequency(round: 2)).to eq 261.63
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