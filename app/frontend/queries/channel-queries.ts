import { queryOptions } from "@tanstack/react-query"
import { api } from "@/lib/api"
import { keys } from "@/lib/query-keys"
import type { Channel } from "@/types/channel"

export const channelQueries = {
  list: () =>
    queryOptions({
      queryKey: keys.channels.all(),
      queryFn: () => api.get<Channel[]>("/channels"),
    }),

  detail: (id: number) =>
    queryOptions({
      queryKey: keys.channels.detail(id),
      queryFn: () => api.get<Channel>(`/channels/${id}`),
    }),
}
