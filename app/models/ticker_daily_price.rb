class TickerDailyPrice < ApplicationRecord
  belongs_to :ticker

  before_save :set_market_times

  def market_open_at
    date.in_time_zone(exchange_timezone).change(**market_hours[:open])
  end

  def market_close_at
    date.in_time_zone(exchange_timezone).change(**market_hours[:close])
  end

  private

  def set_market_times
    self.start_at = market_open_at
    self.end_at   = market_close_at
  end

  def exchange_timezone
    case ticker.primary_exchange
    when "LSE", "LON"        then "London"
    when "TSE", "TYO"        then "Tokyo"
    when "HKEX", "HKG"       then "Hong_Kong"
    when "XETRA", "FRA", "ETR" then "Berlin"
    else                          "Eastern Time (US & Canada)"
    end
  end

  def market_hours
    case exchange_timezone
    when "London"    then { open: { hour: 8, min: 0 },  close: { hour: 16, min: 30 } }
    when "Tokyo"     then { open: { hour: 9, min: 0 },  close: { hour: 15, min: 30 } }
    when "Hong_Kong" then { open: { hour: 9, min: 30 }, close: { hour: 16, min: 0  } }
    when "Berlin"    then { open: { hour: 9, min: 0 },  close: { hour: 17, min: 30 } }
    else                  { open: { hour: 9, min: 30 }, close: { hour: 16, min: 0  } }
    end
  end
end
