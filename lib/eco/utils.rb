module Eco
  module Utils
    def self.chance(pct, opts={})
      success = opts.fetch(:success, true)
      fail = opts.fetch(:success, false)
      roll = rand * 100
      roll <= pct ? success : fail
    end
  end
end