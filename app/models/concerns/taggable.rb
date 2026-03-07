module Taggable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_taggable
      include TaggableInstanceMethods

      has_many :tags, class_name: Tag.to_s, as: :taggable
      has_many :news_sources, through: :tags, source: :source, source_type: News.to_s
    end

    def acts_as_source
      include SourceInstanceMethods

      has_many :tags, class_name: Tag.to_s, as: :source, dependent: :destroy
      has_many :tagged_tickers, through: :tags, source: :taggable, source_type: Ticker.to_s
    end
  end

  module SourceInstanceMethods
    def add_tag(taggable)
      tags.find_or_create_by!(taggable: taggable)
    end
  end

  module TaggableInstanceMethods
    def remove_tag(source)
      tags.find_by!(source: source).destroy
    end
  end
end
