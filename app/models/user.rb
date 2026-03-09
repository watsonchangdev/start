class User < ApplicationRecord
  has_secure_password
  has_many :sessions,         dependent: :destroy
  has_many :trades,           dependent: :destroy
  has_many :stock_positions,  dependent: :destroy
  has_many :option_positions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
                             format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not valid" },
                             uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
