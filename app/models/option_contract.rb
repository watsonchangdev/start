class OptionContract < ApplicationRecord
  belongs_to :ticker
  has_many :daily_prices, class_name: "OptionDailyPrice"
  has_many :minute_prices, class_name: "OptionMinutePrice"
end
