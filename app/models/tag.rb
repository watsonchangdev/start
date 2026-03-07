class Tag < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :taggable, polymorphic: true

end
