class OptionPosition < ApplicationRecord
  enum :status, Enums::Trades::PositionStatus.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }
  enum :side,   Enums::Trades::LegSide.values.to_h        { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :user
  belongs_to :ticker
  belongs_to :option_contract

  validates :status, :side, :quantity, :average_cost_basis, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :average_cost_basis, numericality: { greater_than: 0 }

  def unrealized_pnl
    return BigDecimal("0") unless open?

    mark = option_contract.current_mark_price
    sign = long? ? 1 : -1
    BigDecimal((sign * (mark - average_cost_basis) * quantity * 100).to_s)
  end

  private
end
