class Trade < ApplicationRecord
  enum :trade_type, Enums::Trades::TradeType.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :user
  belongs_to :ticker

  has_one  :stock_detail, class_name: "TradeStockDetail",  dependent: :destroy
  has_many :option_legs,  class_name: "TradeOptionDetail", dependent: :destroy

  validates :trade_type, :executed_at, :total_amount, presence: true
  validates :trade_type, inclusion: { in: Enums::Trades::TradeType.values.map(&:serialize) }

  private
end
