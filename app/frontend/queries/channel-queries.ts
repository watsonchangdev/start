import { queryOptions } from "@tanstack/react-query"
import { api } from "@/lib/api"
import { keys } from "@/lib/query-keys"
import type { Channel, CreateChannelParams } from "@/types/channel"

export const channelQueries = {
  list: () =>
    queryOptions({
      queryKey: keys.channels.all(),
      queryFn: () => api.get<Channel[]>("/channels"),
    }),

  detail: (uuid: string) =>
    queryOptions({
      queryKey: keys.channels.detail(uuid),
      queryFn: () => api.get<Channel>(`/channels/${uuid}`),
    }),
}

export const channelMutations = {
  create: {
    mutationFn: (params: CreateChannelParams) =>
      api.post<Channel>("/channels", { channel: params }),
  },
}
