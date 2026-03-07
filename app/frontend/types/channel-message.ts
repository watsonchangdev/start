export interface ChannelMessage {
  uuid: string
  content: string
  message_type: string | null
  username: string
  created_at: string
}

export interface CreateChannelMessageParams {
  content: string
  message_type?: string
}
