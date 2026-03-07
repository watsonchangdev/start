export const keys = {
  channels: {
    all: () => ["channels"] as const,
    detail: (uuid: string) => ["channels", uuid] as const,
    messages: (channelUuid: string) => ["channels", channelUuid, "messages"] as const,
  },
} as const
