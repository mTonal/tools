class Tonal::Ratio
  class Approximations
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

    # @return [Array] of ratios within cent tolerance of self found using continued fraction approximation
    # @example
    #   Tonal::Ratio.ed(12,1).by_continued_fraction
    #   => [(18/17), (196/185), (1657/1564), (7893/7450), (18904/17843), (3118/2943), (1461/1379), (89/84), (17/16)]
    # @param cents_tolerance
    # @param depth
    # @param max_prime
    # @param conv_limit
    #
    def by_continued_fraction(cents_tolerance: Tonal::Cents::TOLERANCE, depth: DEFAULT_DEPTH, max_prime: DEFAULT_MAX_PRIME, conv_limit: CONVERGENT_LIMIT)
      self_in_cents = to_cents
      within = cents_tolerance.kind_of?(Tonal::Cents) ? cents_tolerance : Tonal::Cents.new(cents: cents_tolerance)
      [].tap do |results|
        ContinuedFraction.new(antecedent.to_f/consequent, conv_limit).convergents_as_rationals.each do |convergent|
          ratio2 = ratio.class.new(convergent.numerator,convergent.denominator)
          results << ratio2 if ratio.class.within_cents?(self_in_cents, ratio2.to_cents, within) && ratio2.within_prime?(max_prime)
          break if results.length >= depth
        end
      end.sort
    end

    # @return [Array] of ratios within cent tolerance of self found using a quotient walk on the fraction tree
    # @example
    #   Tonal::Ratio.ed(12,1).by_quotient_walk(max_prime: 89)
    #   => [(18/17), (196/185), (89/84), (71/67), (53/50), (35/33), (17/16)]
    # @param cents_tolerance
    # @param depth
    # @param max_prime
    #
    def by_quotient_walk(cents_tolerance: Tonal::Cents::TOLERANCE, depth: DEFAULT_DEPTH, max_prime: DEFAULT_MAX_PRIME, conv_limit: CONVERGENT_LIMIT)
      self_in_cents = to_cents
      within = cents_tolerance.kind_of?(Tonal::Cents) ? cents_tolerance : Tonal::Cents.new(cents: cents_tolerance)

      [].tap do |results|
        FractionTree.quotient_walk(to_f, limit: conv_limit).each do |node|
          ratio2 = ratio.class.new(node.weight)
          results << ratio2 if ratio.class.within_cents?(self_in_cents, ratio2.to_cents, within) && ratio2.within_prime?(max_prime)
          break if results.length >= depth
        end
      end.sort
    end

    # @return [Array] of fraction tree ratios within cent tolerance of self
    # @example
    #   Tonal::Ratio.ed(12,1).by_tree_path(max_prime: 17)
    #   => [(18/17), (35/33), (17/16)]
    # @param cents_tolerance
    # @param depth
    # @param max_prime
    #
    def by_tree_path(cents_tolerance: Tonal::Cents::TOLERANCE, depth: DEFAULT_DEPTH, max_prime: DEFAULT_MAX_PRIME)
      self_in_cents = to_cents
      within = cents_tolerance.kind_of?(Tonal::Cents) ? cents_tolerance : Tonal::Cents.new(cents: cents_tolerance)
      [].tap do |results|
        FractionTree.path_to(to_f).each do |node|
          ratio2 = ratio.class.new(node.weight)
          results << ratio2 if ratio.class.within_cents?(self_in_cents, ratio2.to_cents, within) && ratio2.within_prime?(max_prime)
          break if results.length >= depth
        end
      end.sort
    end

    # @return [Array] of ratios within cent tolerance of self found on the ratio grid
    # @example
    #   Tonal::Ratio.new(3,2).by_neighborhood(max_prime: 23, cents_tolerance: 5, max_boundary: 10, max_scale: 60)
    #   => [(175/117), (176/117)]
    # @param cents_tolerance the maximum cents self is allowed from grid ratios
    # @param depth the maximum depth the array will get
    # @param max_prime the maximum prime the grid ratios will contain
    # @param max_boundary the maximum distance grid ratios will be from the scaled ratio
    # @param max_scale the maximum self will be scaled
    #
    def by_neighborhood(cents_tolerance: Tonal::Cents::TOLERANCE, depth: DEFAULT_DEPTH, max_prime: DEFAULT_MAX_PRIME, max_boundary: DEFAULT_MAX_GRID_BOUNDARY, max_scale: DEFAULT_MAX_GRID_SCALE)
      self_in_cents = to_cents
      within = cents_tolerance.kind_of?(Tonal::Cents) ? cents_tolerance : Tonal::Cents.new(cents: cents_tolerance)
      [].tap do |results|
        scale = 1
        boundary = 1

        while results.length <= depth && scale <= max_scale do
          while boundary <= max_boundary
            vacinity = ratio.respond_to?(:to_basic_ratio) ? to_basic_ratio.scale(scale) : ratio.scale(scale)
            self.class.neighbors(away: boundary, vacinity: vacinity).each do |neighbor|
              results << neighbor if ratio.class.within_cents?(self_in_cents, neighbor.to_cents, within) && neighbor.within_prime?(max_prime)
            end
            boundary += 1
          end
          boundary = 1
          scale += 1
        end
      end.uniq(&:to_r).reject{|r| r == ratio}.sort
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
    #   Tonal::Ratio::Approximations.neighbors(vacinity: (3/2r).ratio(reduced:false).scale(256), away: 1)
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
  end
end