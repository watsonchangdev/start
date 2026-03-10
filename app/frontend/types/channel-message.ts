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
  ticker_price: number | null
}

export interface OptionLeg {
  occ_symbol: string
  status: "open" | "closed"
  option_type: "call" | "put"
  side: "long" | "short"
  quantity: number
  strike_price: number
  premium: number
  mark_price: number
  realized_pnl: number
  unrealized_pnl: number
  greeks: { delta: number; theta: number; gamma: number; vega: number; rho: number; iv: number } | null
}

export interface OptionStrategyPosition {
  symbol: string
  status: "open" | "closed"
  spot_price: number
  net_realized_pnl: number
  net_unrealized_pnl: number
  net_delta: number | null
  net_theta: number | null
  net_vega: number | null
  legs: Record<string, OptionLeg[]>  // key: ISO expiration date
}

export interface DataTableMetadata {
  data: OptionStrategyPosition[]
}

export type ChannelMessage =
  | (BaseChannelMessage & { message_type: "media_link"; metadata: MediaLinkMetadata })
  | (BaseChannelMessage & { message_type: "data_table"; metadata: DataTableMetadata })
  | (BaseChannelMessage & { message_type: Exclude<MessageType, "media_link" | "data_table"> })

export interface CreateChannelMessageParams {
  content: string
}
