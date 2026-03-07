class OptionDailyPrice < ApplicationRecord
  belongs_to :ticker
  belongs_to :option_contract
end
