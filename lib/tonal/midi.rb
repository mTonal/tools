module Tonal::Midi
  class Note
    include Comparable

    REFERENCE_FREQUENCY = 440.0
    A4_MIDI_NUMBER = 69
    C4_MIDI_NUMBER = 60

    attr_reader :number, :frequency

    # @return [Tonal::Midi::Note]
    # @example
    #   Tonal::Midi::Note.new(number:60) => 60.0 MIDI
    # @param arg [Numeric, Tonal::Midi::Note]
    #
    def initialize(number: A4_MIDI_NUMBER, frequency: nil)
      if frequency
        raise ArgumentError, "Frequency argument is not Numeric or Tonal::Hertz" unless frequency.kind_of?(Numeric) || frequency.kind_of?(Tonal::Hertz)
        @frequency = Tonal::Hertz.new(frequency)
        @number = (A4_MIDI_NUMBER + 12 * Math.log2(frequency.to_f / REFERENCE_FREQUENCY)).round
      else
        raise ArgumentError, "Number argument is not Integer" unless number.kind_of?(Integer)
        @number = number.kind_of?(self.class) ? number.inspect : number
        @frequency = Tonal::Hertz.new(REFERENCE_FREQUENCY * (2 ** ((number - A4_MIDI_NUMBER) / 12.0)))
      end
    end

    alias :value :number

    # @return [String] representation of self
    def inspect
      "#{number} MIDI"
    end

    def <=>(other)
      number <=> (other.kind_of?(self.class) ? other.number : other)
    end
  end
end
