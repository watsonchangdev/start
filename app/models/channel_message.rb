class ChannelMessage < ApplicationRecord
  belongs_to :channel
  belongs_to :sent_by, polymorphic: true

  private

end
