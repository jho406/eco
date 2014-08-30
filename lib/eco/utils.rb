module Eco
  module Utils
    def self.chance(pct, opts)
      success = opts.fetch(:success, true)
      fail = opts.fetch(:success, false)
      roll = rand * 100
      pct <= roll ? success : fail
    end
  end
end
