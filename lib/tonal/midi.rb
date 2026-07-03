module Tonal::Midi
  class Note
    include Comparable

    A4_MIDI_NUMBER = 69
    C4_MIDI_NUMBER = 60
    DEFAULT_MODULO = 12

    attr_reader :number, :modulo, :reference_number, :reference_frequency

    # @return [Tonal::Midi::Note]
    # @example
    #   Tonal::Midi::Note.new(number: 60) => 60 MIDI
    #   Tonal::Midi::Note.new(frequency: 261.63) => 60 MIDI
    # @param number [Integer, nil] the MIDI note number. Mutually exclusive with frequency:
    # @param frequency [Numeric, Tonal::Hertz, nil] the frequency in Hz. Mutually exclusive with number:
    # @param modulo [Integer] the number of steps per octave
    # @param reference_number [Integer] the MIDI note number that anchors the number/frequency conversion
    # @param reference_frequency [Numeric] the frequency (Hz) that anchors the number/frequency conversion
    #
    def initialize(number: nil, frequency: nil, modulo: DEFAULT_MODULO, reference_number: A4_MIDI_NUMBER, reference_frequency: Tonal::Hertz::REFERENCE_FREQUENCY)
      raise ArgumentError, "Provide either number: or frequency:, not both" if number && frequency

      @modulo = modulo
      @reference_number = reference_number
      @reference_frequency = reference_frequency.to_f
      if frequency
        raise ArgumentError, "Frequency argument is not Numeric or Tonal::Hertz" unless frequency.kind_of?(Numeric) || frequency.kind_of?(Tonal::Hertz)
        @frequency = Tonal::Hertz.new(frequency)
        @number = (@reference_number + modulo * Math.log2(frequency.to_f / @reference_frequency)).round
      else
        number = @reference_number if number.nil?
        raise ArgumentError, "Number argument is not Integer" unless number.kind_of?(Integer)
        @number = number
        @frequency = Tonal::Hertz.new(@reference_frequency * (2 ** ((number - @reference_number) / modulo.to_f)))
      end
    end

    alias :value :number

    # @return [Float] the frequency corresponding to the MIDI note number
    # @example
    #   Tonal::Midi::Note.new(number:60).frequency => 261.6255653005986
    # @param round [Integer, nil] the number of decimal places to round the frequency to, or nil for no rounding
    #
    def frequency(round: nil)
      round ? @frequency.to_f.round(round) : @frequency.to_f
    end

    # @return [String] representation of self
    def inspect
      "#{number} MIDI"
    end

    def <=>(other)
      number <=> (other.kind_of?(self.class) ? other.number : other)
    end
  end
end
