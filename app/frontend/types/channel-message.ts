export type MessageType = "user_message" | "data_table" | "notification" | "media_link"

export interface ChannelMessage {
  uuid: string
  content: string
  message_type: MessageType
  metadata: Record<string, unknown>
  username: string
  created_at: string
}

export interface CreateChannelMessageParams {
  content: string
}
