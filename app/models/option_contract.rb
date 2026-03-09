class OptionContract < ApplicationRecord
  belongs_to :ticker
  has_many :daily_prices, class_name: "OptionDailyPrice"
  has_many :minute_prices, class_name: "OptionMinutePrice"

  enum :option_type, Enums::Trades::OptionType.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }

  def current_mark_price
    price = minute_prices.order(end_at: :desc).first ||
            daily_prices.order(date: :desc).first
    BigDecimal((price&.vwap || 0).to_s)
  end
end
