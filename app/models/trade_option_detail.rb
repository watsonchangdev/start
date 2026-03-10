class TradeOptionDetail < ApplicationRecord
  enum :side_type,   Enums::Trades::SideType.values.to_h   { |v| [ v.serialize.to_sym, v.serialize ] }
  enum :action_type, Enums::Trades::ActionType.values.to_h  { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :trade
  belongs_to :option_contract

  validates :side_type, :action_type, :quantity, :premium, presence: true
  validates :side_type,   inclusion: { in: Enums::Trades::SideType.values.map(&:serialize) }
  validates :action_type, inclusion: { in: Enums::Trades::ActionType.values.map(&:serialize) }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :premium,  numericality: { greater_than: 0 }

  after_create :update_position

  private

  def update_position
    PositionService.update_from_option_trade(self)
  end
end
