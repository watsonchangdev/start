module OptionPositions
  # Greeks for a single option leg. Only constructed when a live quote is available.
  class OptionGreeks < T::Struct
    const :delta, BigDecimal  # price sensitivity to underlying move
    const :theta, BigDecimal  # daily time decay (per share)
    const :gamma, BigDecimal  # rate of delta change
    const :vega,  BigDecimal  # sensitivity to 1% IV move
    const :rho,   BigDecimal  # sensitivity to interest rate move
    const :iv,    BigDecimal  # implied volatility (0.0–1.0)
  end

  # A single leg within a strategy (one contract, long or short).
  class OptionLeg < T::Struct
    const :occ_symbol,      String      # e.g. "AAPL250620C00190000"
    const :status,          Enums::Trades::PositionStatus
    const :option_type,     Enums::Trades::OptionType # call/put
    const :side,            Enums::Trades::LegSide # long/short
    const :quantity,        Integer     # number of contracts (always positive)
    const :strike_price,    BigDecimal
    const :expiration_date, Date
    const :trade_price,     BigDecimal          # average premium paid/received per share
    const :mark_price,      BigDecimal          # current mid-market premium per share
    const :greeks,          T.nilable(OptionGreeks)  # nil when no live quote available
    const :realized_pnl,    BigDecimal  # locked in from fully closed legs
    const :unrealized_pnl,  BigDecimal          # (mark - trade) * qty * 100, sign-adjusted for side
  end

  # An options strategy position — one or more legs treated as a unit.
  # Single leg, vertical spread, iron condor, straddle, etc.
  class OptionStrategyPosition < T::Struct
    const :symbol,                  String
    const :spot_price,              BigDecimal  # current stock price at time of valuation
    const :legs,                    T::Hash[Date, T::Array[OptionLeg]]
    const :net_realized_pnl,        BigDecimal              # locked in from fully closed legs
    const :net_unrealized_pnl,      BigDecimal              # sum of open leg unrealized P&Ls
    const :net_delta,               T.nilable(BigDecimal)   # sum of leg deltas
    const :net_theta,               T.nilable(BigDecimal)   # sum of leg thetas (daily decay)
    const :net_vega,                T.nilable(BigDecimal)   # sum of leg vegas
    const :status,                  Enums::Trades::PositionStatus  # open if any leg is open
  end
end
