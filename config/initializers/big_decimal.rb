# frozen_string_literal: true

require "bigdecimal"

# Display BigDecimal as a plain decimal string (e.g. "176.83") instead of
# scientific notation (e.g. "0.17683e3") in console and logs.
BigDecimal.define_method(:inspect) { "BigDecimal(#{to_s('F')})" }
