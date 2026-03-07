import { queryOptions } from "@tanstack/react-query"
import { api } from "@/lib/api"
import { keys } from "@/lib/query-keys"
import type { ChannelMessage, CreateChannelMessageParams } from "@/types/channel-message"

export const channelMessageQueries = {
  list: (channelId: number) =>
    queryOptions({
      queryKey: keys.channels.messages(channelId),
      queryFn: () => api.get<ChannelMessage[]>(`/channels/${channelId}/messages`),
      enabled: channelId > 0,
    }),
}

export const channelMessageMutations = {
  create: (channelId: number) => ({
    mutationFn: (params: CreateChannelMessageParams) =>
      api.post<ChannelMessage>(`/channels/${channelId}/messages`, {
        channel_message: params,
      }),
  }),
}
