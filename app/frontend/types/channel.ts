export type ChannelType = "ticker" | "chat" | "feature"

export interface Channel {
  uuid: string
  name: string
  description: string | null
  channel_type: ChannelType
  created_at: string
}

export interface CreateChannelParams {
  name: string
  channel_type: ChannelType
  description?: string
}
