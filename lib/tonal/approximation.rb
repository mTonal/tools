class Tonal::Ratio
  class Approximation
    DEFAULT_MAX_PRIME = Float::INFINITY
    DEFAULT_MAX_GRID_SCALE = 100
    DEFAULT_MAX_GRID_BOUNDARY = 5
    DEFAULT_DEPTH = Float::INFINITY
    DEFAULT_COMPLEXITY_AMOUNT = 50.0
    CONVERGENT_LIMIT = 10

    extend Forwardable
    def_delegators :@ratio, :antecedent, :consequent, :to_cents, :to_basic_ratio, :to_f

    attr_reader :ratio

    def initialize(ratio:)
      raise ArgumentError, "Tonal::Ratio required" unless ratio.kind_of?(Tonal::Ratio)
      @ratio = ratio
    end

    # @return [Tonal::Ratio::Approximation::Set] of ratios within cent tolerance of self found using continued fraction approximation
    # @example
    #   Tonal::Ratio.ed(12,1).approximate.by_continued_fraction
    #   => (4771397596969315/4503599627370496): [(18/17), (196/185), (1657/1564), (7893/7450), (18904/17843), (3118/2943), (1461/1379), (89/84), (17/16)]
    # @param cents_tolerance the cents tolerance used to scope the collection
    # @param depth the maximum number of ratios in the collection
    # @param max_prime the maximum prime number to allow in the collection
    # @param conv_limit the number of convergents to limit the ContinuedFraction method
    #
    def by_continued_fraction(cents_tolerance: Tonal::Cents::TOLERANCE, depth: DEFAULT_DEPTH, max_prime: DEFAULT_MAX_PRIME, conv_limit: CONVERGENT_LIMIT)
      self_in_cents = to_cents
      within = cents_tolerance.kind_of?(Tonal::Cents) ? cents_tolerance : Tonal::Cents.new(cents: cents_tolerance)
      Set.new(ratio: ratio).tap do |set|
        ContinuedFraction.new(antecedent.to_f/consequent, conv_limit).convergents.each do |convergent|
          ratio2 = ratio.class.new(convergent.numerator,convergent.denominator)
          set.ratios << ratio2 if ratio.class.within_cents?(self_in_cents, ratio2.to_cents, within) && ratio2.within_prime?(max_prime)
          break if set.length >= depth
        end
      end
    end

    # @return [Tonal::Ratio::Approximation::Set] of ratios within cent tolerance of self found using a quotient walk on the fraction tree
    # @example
    #   Tonal::Ratio.ed(12,1).approximate.by_quotient_walk(max_prime: 89)
    #   => (4771397596969315/4503599627370496): [(18/17), (196/185), (89/84), (71/67), (53/50), (35/33), (17/16)]
    # @param cents_tolerance the cents tolerance used to scope the collection
    # @param depth the maximum number of ratios in the collection
    # @param max_prime the maximum prime number to allow in the collection
    # @param conv_limit the number of convergents to limit the ContinuedFraction method
    #
    def by_quotient_walk(cents_tolerance: Tonal::Cents::TOLERANCE, depth: DEFAULT_DEPTH, max_prime: DEFAULT_MAX_PRIME, conv_limit: CONVERGENT_LIMIT)
      self_in_cents = to_cents
      within = cents_tolerance.kind_of?(Tonal::Cents) ? cents_tolerance : Tonal::Cents.new(cents: cents_tolerance)

      Set.new(ratio: ratio).tap do |set|
        FractionTree.quotient_walk(to_f, limit: conv_limit).each do |node|
          ratio2 = ratio.class.new(node.weight)
          set.ratios << ratio2 if ratio.class.within_cents?(self_in_cents, ratio2.to_cents, within) && ratio2.within_prime?(max_prime)
          break if set.length >= depth
        end
      end
    end

    # @return [Tonal::Ratio::Approximation::Set] of fraction tree ratios within cent tolerance of self
    # @example
    #   Tonal::Ratio.ed(12,1).approximate.by_tree_path(max_prime: 17)
    #   => (4771397596969315/4503599627370496): [(18/17), (35/33), (17/16)]
    # @param cents_tolerance the cents tolerance used to scope the collection
    # @param depth the maximum number of ratios in the collection
    # @param max_prime the maximum prime number to allow in the collection
    #
    def by_tree_path(cents_tolerance: Tonal::Cents::TOLERANCE, depth: DEFAULT_DEPTH, max_prime: DEFAULT_MAX_PRIME)
      self_in_cents = to_cents
      within = cents_tolerance.kind_of?(Tonal::Cents) ? cents_tolerance : Tonal::Cents.new(cents: cents_tolerance)
      Set.new(ratio: ratio).tap do |set|
        FractionTree.path_to(to_f).each do |node|
          ratio2 = ratio.class.new(node.weight)
          set.ratios << ratio2 if ratio.class.within_cents?(self_in_cents, ratio2.to_cents, within) && ratio2.within_prime?(max_prime)
          break if set.length >= depth
        end
      end
    end

    # @return [Tonal::Ratio::Approximation::Set] of superparticular approximations within cent tolerance of self
    # @example
    #   Tonal::Ratio.new(3/2r).approximate.by_superparticular
    #   => (3/2): [(1098/730), (1095/728), (1092/726), (1089/724), (1086/722), (1083/720), (1080/718), (1077/716), (1074/714), (1071/712), (1068/710), (1065/708), (1062/706), (1059/704), (1056/702), (1053/700), (1050/698), (1047/696), (1044/694), (1041/692)]
    # @param cents_tolerance the cents tolerance used to scope the collection
    # @param depth the maximum number of ratios in the collection
    # @param max_prime the maximum prime number to allow in the collection
    # @param superpart if the superior part is the numerator or denominator
    #
    def by_superparticular(cents_tolerance: Tonal::Cents::TOLERANCE, depth: 20, max_prime: DEFAULT_MAX_PRIME, superpart: :upper)
      self_in_cents = to_cents
      within = cents_tolerance.kind_of?(Tonal::Cents) ? cents_tolerance : Tonal::Cents.new(cents: cents_tolerance)
      Set.new(ratio: ratio).tap do |set|
        n = 1
        while true do
          ratio2 = ratio.class.superparticular(n, factor: ratio.to_r, superpart:)
          set.ratios << ratio2 if ratio.class.within_cents?(self_in_cents, ratio2.to_cents, within) && ratio2.within_prime?(max_prime) && ratio2 != ratio
          break if set.length >= depth
          n += 1
        end
      end
    end

    # @return [Array] of ratios within cent tolerance of self found on the ratio grid
    # @example
    #   Tonal::Ratio.new(3,2).approximate.by_neighborhood(max_prime: 23, cents_tolerance: 5, max_boundary: 10, max_scale: 60)
    #   => (3/2): [(175/117), (176/117)]
    # @param cents_tolerance the cents tolerance used to scope the collection
    # @param depth the maximum number of ratios in the collection
    # @param max_prime the maximum prime number to allow in the collection
    # @param max_boundary the maximum distance grid ratios will be from the scaled ratio
    # @param max_scale the maximum self will be scaled
    #
    def by_neighborhood(cents_tolerance: Tonal::Cents::TOLERANCE, depth: DEFAULT_DEPTH, max_prime: DEFAULT_MAX_PRIME, max_boundary: DEFAULT_MAX_GRID_BOUNDARY, max_scale: DEFAULT_MAX_GRID_SCALE)
      self_in_cents = to_cents
      within = cents_tolerance.kind_of?(Tonal::Cents) ? cents_tolerance : Tonal::Cents.new(cents: cents_tolerance)
      Set.new(ratio: ratio).tap do |set|
        scale = 1
        boundary = 1

        while set.length <= depth && scale <= max_scale do
          while boundary <= max_boundary
            vacinity = ratio.respond_to?(:to_basic_ratio) ? to_basic_ratio.scale(scale) : ratio.scale(scale)
            self.class.neighbors(away: boundary, vacinity: vacinity).each do |neighbor|
              set.ratios << neighbor if ratio.class.within_cents?(self_in_cents, neighbor.to_cents, within) && neighbor.within_prime?(max_prime) && neighbor != ratio
            end
            boundary += 1
          end
          boundary = 1
          scale += 1
        end
      end
    end

    # @return [Array] of bounding ratios in the ratio grid vacinity of antecedent/consequent scaled by scale
    # @example
    #   Tonal::ReducedRatio.new(3,2).neighborhood(scale: 256, boundary: 2)
    #     => [(768/514), (766/512), (768/513), (767/512), (768/512), (769/512), (768/511), (770/512), (768/510)]
    # @param scale [Integer] used to scale antecedent/consequent on coordinate system
    # @param boundary [Integer] limit within which to calculate neighboring ratios
    #
    def neighborhood(scale: 2**0, boundary: 1)
      scale = scale.round
      vacinity = ratio.respond_to?(:to_basic_ratio) ? to_basic_ratio.scale(scale) : ratio.scale(scale)
      SortedSet.new([].tap do |ratio_list|
                      1.upto(boundary) do |away|
                        ratio_list << self.class.neighbors(away: away, vacinity: vacinity)
                      end
                    end.flatten).to_a
    end

    # @return [Array] an array of Tonal::Ratio neighbors in the scaled ratio's grid neighborhood
    # @example
    #   Tonal::Ratio::Approximation.neighbors(vacinity: (3/2r).ratio(reduced:false).scale(256), away: 1)
    #     => [(768/513), (767/512), (768/512), (769/512), (768/511)]
    # @param away [Integer] the neighbors distance away from self's antecedent and consequent
    #
    def self.neighbors(vacinity:, away: 1)
      [vacinity,
       vacinity.class.new(vacinity.antecedent+away, vacinity.consequent),
       vacinity.class.new(vacinity.antecedent-away, vacinity.consequent),
       vacinity.class.new(vacinity.antecedent, vacinity.consequent+away),
       vacinity.class.new(vacinity.antecedent, vacinity.consequent-away),
       vacinity.class.new(vacinity.antecedent+away, vacinity.consequent+away),
       vacinity.class.new(vacinity.antecedent+away, vacinity.consequent-away),
       vacinity.class.new(vacinity.antecedent-away, vacinity.consequent+away),
       vacinity.class.new(vacinity.antecedent-away, vacinity.consequent-away)]
    end

    class Set
      extend Forwardable
      def_delegators :@ratios, :count, :length, :min, :max, :entries, :all?, :any?, :reject, :map

      attr_reader :ratios, :ratio

      def initialize(ratio:)
        @ratio = ratio
        @ratios = SortedSet.new
      end
      alias :approximations :entries

      def inspect
        "#{ratio}: #{entries}"
      end
    end
  end
end