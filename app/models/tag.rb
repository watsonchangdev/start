class Tag < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :taggable, polymorphic: true

  after_create_commit { freeze }

  after_create_commit :publish_news_tagged, if: -> { source_type == "News" && taggable_type == "Ticker" }

  private

  def publish_news_tagged
    Rails.configuration.event_store.publish(
      Events::NewsCreated.new(data: {
        uuid:     source.uuid,
        headline: source.headline,
        ticker:   { uuid: taggable.uuid }
      }),
      stream_name: "news"
    )
  end
end
