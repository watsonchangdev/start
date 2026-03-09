class StockPosition < ApplicationRecord
  enum :status, Enums::Trades::PositionStatus.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :user
  belongs_to :ticker

  validates :status, :quantity, :average_cost_basis, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :average_cost_basis, numericality: { greater_than: 0 }

  private
end
