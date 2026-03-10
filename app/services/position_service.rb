class PositionService
  class << self
    # --- Read ---

    # Groups a user's OptionPosition records by ticker into OptionStrategyPosition value objects.
    def get_realtime_option_positions(option_positions)
      option_positions.group_by(&:ticker).map do |ticker, positions|
        spot      = BigDecimal(ticker.get_current_price.to_s)
        legs      = positions.map { |p| build_option_leg(p) }
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

    # --- Write ---

    def update_from_stock_trade(detail)
      trade = detail.trade
      qty   = BigDecimal(detail.quantity.to_s)
      price = BigDecimal(detail.price.to_s)

      position = StockPosition.find_or_initialize_by(user: trade.user, ticker: trade.ticker)

      if detail.buy?
        if position.new_record?
          position.status             = "open"
          position.quantity           = qty
          position.average_cost_basis = price
          position.save!
        else
          position.with_lock do
            new_qty = position.quantity + qty
            position.average_cost_basis = ((position.quantity * position.average_cost_basis) + (qty * price)) / new_qty
            position.quantity           = new_qty
            position.status             = "open"
            position.save!
          end
        end
      else # sell
        position.with_lock do
          position.realized_pnl = position.realized_pnl + (price - position.average_cost_basis) * qty
          position.quantity     = position.quantity - qty
          position.status       = "closed" if position.quantity <= 0
          position.save!
        end
      end
    end

    def update_from_option_trade(detail)
      trade    = detail.trade
      contract = detail.option_contract
      qty      = detail.quantity
      premium  = BigDecimal(detail.premium.to_s)

      if detail.open?
        side     = detail.buy? ? "long" : "short"
        position = OptionPosition.find_or_initialize_by(user: trade.user, option_contract: contract, side: side)

        if position.new_record?
          position.ticker             = trade.ticker
          position.status             = "open"
          position.quantity           = qty
          position.average_cost_basis = premium
          position.save!
        else
          position.with_lock do
            new_qty = position.quantity + qty
            position.average_cost_basis = ((position.quantity * position.average_cost_basis) + (qty * premium)) / new_qty
            position.quantity           = new_qty
            position.save!
          end
        end
      else # close: buy-to-close targets short, sell-to-close targets long
        closing_side = detail.buy? ? "short" : "long"
        position     = OptionPosition.find_by!(user: trade.user, option_contract: contract, side: closing_side)
        position.with_lock do
          realized = if position.long?
            (premium - position.average_cost_basis) * qty * 100
          else
            (position.average_cost_basis - premium) * qty * 100
          end
          position.realized_pnl = position.realized_pnl + realized
          position.quantity     = position.quantity - qty
          position.status       = "closed" if position.quantity <= 0
          position.save!
        end
      end
    end

    private

    def build_option_leg(position)
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
        trade_price:     position.average_cost_basis,
        mark_price:      mark,
        greeks:          nil,
        realized_pnl:    position.realized_pnl,
        unrealized_pnl:  position.unrealized_pnl
      )
    end
  end
end
