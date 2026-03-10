class StockPosition < ApplicationRecord
  enum :status, Enums::Trades::PositionStatus.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :user
  belongs_to :ticker

  validates :status, :quantity, :average_cost_basis, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :average_cost_basis, numericality: { greater_than: 0 }

  def unrealized_pnl
    return BigDecimal("0") unless open?

    current_price = ticker.get_current_price
    return BigDecimal("0") if current_price.nil?

    (BigDecimal(current_price.to_s) - average_cost_basis) * quantity
  end

  private
end
