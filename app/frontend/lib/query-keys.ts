export const keys = {
  channels: {
    all: () => ["channels"] as const,
    detail: (id: number) => ["channels", id] as const,
    messages: (channelId: number) => ["channels", channelId, "messages"] as const,
  },
} as const
