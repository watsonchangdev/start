export interface Channel {
  uuid: string
  name: string
  description: string | null
  created_at: string
}

export interface CreateChannelParams {
  name: string
  description?: string
}
