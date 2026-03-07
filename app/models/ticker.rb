class Ticker < ApplicationRecord
  include Taggable
  
  acts_as_taggable

  has_many :option_contracts
  has_many :daily_prices, class_name: "TickerDailyPrice"
  has_many :minute_prices, class_name: "TickerMinutePrice"
end
