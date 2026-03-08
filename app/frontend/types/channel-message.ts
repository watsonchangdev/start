export type MessageType = "user_message" | "data_table" | "notification" | "media_link"

interface BaseChannelMessage {
  uuid: string
  content: string
  username: string
  created_at: string
}

export interface MediaLinkMetadata {
  news_uuid: string
  source_url: string
  thumbnail_url: string
  ticker_price: number | null
}

export type ChannelMessage =
  | (BaseChannelMessage & { message_type: "media_link"; metadata: MediaLinkMetadata })
  | (BaseChannelMessage & { message_type: Exclude<MessageType, "media_link"> })

export interface CreateChannelMessageParams {
  content: string
}
