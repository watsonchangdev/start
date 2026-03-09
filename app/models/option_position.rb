class OptionPosition < ApplicationRecord
  enum :status, Enums::Trades::PositionStatus.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }
  enum :side,   Enums::Trades::LegSide.values.to_h        { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :user
  belongs_to :ticker
  belongs_to :option_contract

  validates :status, :side, :quantity, :average_cost_basis, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :average_cost_basis, numericality: { greater_than: 0 }

  private
end
