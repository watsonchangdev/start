class TradeStockDetail < ApplicationRecord
  enum :side_type, Enums::Trades::SideType.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :trade

  validates :side_type, :quantity, :price, presence: true
  validates :side_type, inclusion: { in: Enums::Trades::SideType.values.map(&:serialize) }
  validates :quantity, :price, numericality: { greater_than: 0 }

  after_create :update_position

  private

  def update_position
    PositionService.update_from_stock_trade(self)
  end
end
