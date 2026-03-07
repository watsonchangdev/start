export interface ChannelMessage {
  uuid: string
  content: string
  username: string
  created_at: string
}

export interface CreateChannelMessageParams {
  content: string
}
