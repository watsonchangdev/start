export const keys = {
  channels: {
    all: () => ["channels"] as const,
    detail: (id: number) => ["channels", id] as const,
  },
} as const
