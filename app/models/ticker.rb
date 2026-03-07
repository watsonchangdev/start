class Ticker < ApplicationRecord
  has_many :option_contracts
  has_many :daily_prices, class_name: "TickerDailyPrice"
  has_many :minute_prices, class_name: "TickerMinutePrice"
end
