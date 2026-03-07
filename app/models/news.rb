class News < ApplicationRecord
  include Taggable

  acts_as_source
end
