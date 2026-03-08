class TickerMinutePrice < ApplicationRecord
  LOOKBACK_PERIODS         = 20
  VOLUME_SPIKE_FACTOR      = 2.0
  PRICE_RANGE_SPIKE_FACTOR = 2.0

  belongs_to :ticker

  after_create_commit :check_for_volatility

  private

  # TODO: WIP
  def check_for_volatility
    recent = ticker.minute_prices
                   .where(end_at: ...start_at)
                   .order(end_at: :desc)
                   .limit(LOOKBACK_PERIODS)

    return if recent.size < LOOKBACK_PERIODS

    avg_volume      = recent.average(:volume).to_f
    avg_price_range = recent.average("price_high - price_low").to_f
    price_range     = price_high - price_low

    volume_spike      = avg_volume > 0      && volume      >= avg_volume      * VOLUME_SPIKE_FACTOR
    price_range_spike = avg_price_range > 0 && price_range >= avg_price_range * PRICE_RANGE_SPIKE_FACTOR

    # TODO: If price spike, then emit price spike event, show current vs. previous
    # TODO: if volume spike, then emit volume spike event, show current vs. previous
  end
end
