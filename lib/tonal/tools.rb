module Tonal
  require "yaml"
  require "json"
  require "prime"
  require "matrix"
  require "sorted_set"
  require "continued_fractions"
  require "fraction_tree"
  require "tonal/comma"
  require "tonal/cents"
  require "tonal/hertz"
  require "tonal/log"
  require "tonal/log2"
  require "tonal/approximation"
  require "tonal/ratio"
  require "tonal/reduced_ratio"
  require "tonal/interval"
  require "tonal/step"
  require "tonal/extensions"
  require "tonal/irb_helpers"
end

if ENV["MTONAL_IRB_HELPERS"]
  Tonal.include_irb_helpers
  puts 'mTonal IRB helpers have been enabled.'
end
