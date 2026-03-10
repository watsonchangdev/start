class OptionPositionResource
  include Alba::Resource

  # Serializes an OptionPositions::OptionStrategyPosition value object.

  attributes :symbol, :status

  attribute :spot_price do |pos|
    pos.spot_price.to_f
  end

  attribute :net_realized_pnl do |pos|
    pos.net_realized_pnl.to_f
  end

  attribute :net_unrealized_pnl do |pos|
    pos.net_unrealized_pnl.to_f
  end

  attribute :net_delta do |pos|
    pos.net_delta&.to_f
  end

  attribute :net_theta do |pos|
    pos.net_theta&.to_f
  end

  attribute :net_vega do |pos|
    pos.net_vega&.to_f
  end

  attribute :legs do |pos|
    pos.legs.transform_keys(&:iso8601).transform_values do |exp_legs|
      exp_legs.map do |leg|
        {
          occ_symbol:    leg.occ_symbol,
          status:        leg.status.serialize,
          option_type:   leg.option_type.serialize,
          side:          leg.side.serialize,
          quantity:      leg.quantity,
          strike_price:  leg.strike_price.to_f,
          premium:   leg.premium.to_f,
          mark_price:    leg.mark_price.to_f,
          realized_pnl:  leg.realized_pnl.to_f,
          unrealized_pnl: leg.unrealized_pnl.to_f,
          greeks:        leg.greeks && {
            delta: leg.greeks.delta.to_f,
            theta: leg.greeks.theta.to_f,
            gamma: leg.greeks.gamma.to_f,
            vega:  leg.greeks.vega.to_f,
            rho:   leg.greeks.rho.to_f,
            iv:    leg.greeks.iv.to_f
          }
        }
      end
    end
  end
end
