export const keys = {
  channels: {
    all: () => ["channels"] as const,
    detail: (id: number) => ["channels", id] as const,
    messages: (channelUuid: string) => ["channels", channelUuid, "messages"] as const,
  },
} as const
