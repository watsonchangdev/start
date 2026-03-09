import { queryOptions } from "@tanstack/react-query"
import { api } from "@/lib/api"
import { keys } from "@/lib/query-keys"
import type { ChannelMessage, CreateChannelMessageParams } from "@/types/channel-message"

export const channelMessageQueries = {
  list: (channelUuid: string) =>
    queryOptions({
      queryKey: keys.channels.messages(channelUuid),
      queryFn: () => api.get<ChannelMessage[]>(`/channels/${channelUuid}/messages`),
      enabled: !!channelUuid,
    }),
}

export const channelMessageMutations = {
  create: (channelUuid: string) => ({
    mutationFn: (params: CreateChannelMessageParams) =>
      api.post<ChannelMessage>(`/channels/${channelUuid}/messages`, {
        channel_message: params,
      }),
  }),

  optionPositions: (channelUuid: string) => ({
    mutationFn: () =>
      api.post<ChannelMessage>(`/channels/${channelUuid}/option_positions`, {}),
  }),
}
