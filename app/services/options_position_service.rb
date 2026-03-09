class OptionsPositionService
  class << self
    def get_realtime_option_position(trade)
      raise ArgumentError, "trade must be option type" unless trade.option?

      ticker = trade.ticker
      spot   = BigDecimal(ticker.get_current_price.to_s)

      legs = trade.option_legs.includes(:option_contract).map do |leg|
        contract   = leg.option_contract
        leg_side   = leg.buy? ? Enums::Trades::LegSide::Long : Enums::Trades::LegSide::Short
        leg_status = leg.open? ? Enums::Trades::PositionStatus::Open : Enums::Trades::PositionStatus::Closed
        mark       = contract.current_mark_price
        sign       = leg_side == Enums::Trades::LegSide::Long ? 1 : -1

        unrealized_pnl = if leg_status == Enums::Trades::PositionStatus::Open
          BigDecimal((sign * (mark - leg.premium) * leg.quantity * 100).to_s)
        else
          BigDecimal("0")
        end

        OptionPositions::OptionLeg.new(
          occ_symbol:      contract.symbol,
          status:          leg_status,
          option_type:     Enums::Trades::OptionType.deserialize(contract.option_type),
          side:            leg_side,
          quantity:        leg.quantity,
          strike_price:    contract.strike_price,
          expiration_date: contract.expires_on,
          trade_price:     leg.premium,
          mark_price:      mark,
          greeks:          nil,
          realized_pnl:    BigDecimal("0"),  # requires pairing with closing trade
          unrealized_pnl:  unrealized_pnl
        )
      end

      strategy_status = legs.any? { |l| l.status == Enums::Trades::PositionStatus::Open } \
        ? Enums::Trades::PositionStatus::Open \
        : Enums::Trades::PositionStatus::Closed

      OptionPositions::OptionStrategyPosition.new(
        symbol:             ticker.symbol,
        spot_price:         spot,
        legs:               legs,
        net_realized_pnl:   legs.sum(&:realized_pnl),
        net_unrealized_pnl: legs.sum(&:unrealized_pnl),
        net_delta:          nil,
        net_theta:          nil,
        net_vega:           nil,
        status:             strategy_status
      )
    end
  end
end
