export interface ChannelMessageSender {
  id: number
  type: "User" | "ChannelBot"
  display_name: string
}

export interface ChannelMessage {
  id: number
  uuid: string
  content: string
  message_type: string | null
  sent_by: ChannelMessageSender
  created_at: string
}

export interface CreateChannelMessageParams {
  content: string
  message_type?: string
}
