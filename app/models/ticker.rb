class Ticker < ApplicationRecord
  include Taggable

  acts_as_taggable

  has_many :option_contracts
  has_many :daily_prices,    class_name: "TickerDailyPrice"
  has_many :minute_prices,   class_name: "TickerMinutePrice"

  def get_current_price
    minute = minute_prices.order(end_at: :desc).first
    daily  = daily_prices.order(date: :desc).first

    record = [ minute, daily ].compact.max_by do |r|
      r.is_a?(TickerMinutePrice) ? r.end_at : r.date.to_time
    end

    extract_price(record)
  end

  def get_price_as_of(as_of_at)
    minute = minute_prices.where(end_at: ..as_of_at).order(end_at: :desc).first
    record = minute || daily_prices.where(date: ..as_of_at.to_date).order(date: :desc).first

    extract_price(record)
  end

  private

  def extract_price(record)
    return nil if record.nil?

    record.vwap || (record.price_high + record.price_low + record.price_close) / 3.0
  end
end
