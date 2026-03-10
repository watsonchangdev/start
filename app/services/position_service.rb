class PositionService
  class << self
    def update_from_stock_trade(detail)
      trade  = detail.trade
      qty    = BigDecimal(detail.quantity.to_s)
      price  = BigDecimal(detail.price.to_s)

      position = StockPosition.find_or_initialize_by(user: trade.user, ticker: trade.ticker)

      if detail.buy? # buy
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
          realized              = (price - position.average_cost_basis) * qty
          position.realized_pnl = position.realized_pnl + realized
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
        position = OptionPosition.find_or_initialize_by(user: trade.user, option_contract: contract)

        if position.new_record?
          position.ticker             = trade.ticker
          position.side               = side
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
      else # close
        position = OptionPosition.find_by!(user: trade.user, option_contract: contract)
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
  end
end
