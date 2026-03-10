class OptionsPositionService
  class << self
    def get_realtime_option_positions(option_positions)
      option_positions.group_by(&:ticker).map do |ticker, positions|
        spot = BigDecimal(ticker.get_current_price.to_s)

        legs      = positions.map { |p| build_leg(p) }
        open_legs = legs.select { |l| l.status == Enums::Trades::PositionStatus::Open }

        OptionPositions::OptionStrategyPosition.new(
          symbol:             ticker.symbol,
          spot_price:         spot,
          legs:               legs.group_by(&:expiration_date),
          net_realized_pnl:   legs.sum(&:realized_pnl),
          net_unrealized_pnl: open_legs.sum(&:unrealized_pnl),
          net_delta:          nil,
          net_theta:          nil,
          net_vega:           nil,
          status:             open_legs.any? ? Enums::Trades::PositionStatus::Open : Enums::Trades::PositionStatus::Closed
        )
      end
    end

    private

    def build_leg(position)
      contract = position.option_contract
      mark     = contract.current_mark_price

      OptionPositions::OptionLeg.new(
        occ_symbol:      contract.symbol,
        status:          Enums::Trades::PositionStatus.deserialize(position.status),
        option_type:     Enums::Trades::OptionType.deserialize(contract.option_type),
        side:            Enums::Trades::LegSide.deserialize(position.side),
        quantity:        position.quantity,
        strike_price:    contract.strike_price,
        expiration_date: contract.expires_on,
        premium:     position.average_cost_basis,
        mark_price:      mark,
        greeks:          nil,
        realized_pnl:    position.realized_pnl,
        unrealized_pnl:  position.unrealized_pnl
      )
    end
  end
end
