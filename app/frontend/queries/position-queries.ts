import { queryOptions } from "@tanstack/react-query"
import { api } from "@/lib/api"
import { keys } from "@/lib/query-keys"
import type { OptionStrategyPosition } from "@/types/channel-message"

interface OptionPositionsParams {
  symbol?: string
  status?: string
}

export const positionQueries = {
  options: (params?: OptionPositionsParams) =>
    queryOptions({
      queryKey: keys.positions.options(params),
      queryFn: () => {
        const searchParams = new URLSearchParams()
        if (params?.symbol) searchParams.set("symbol", params.symbol)
        if (params?.status) searchParams.set("status", params.status)
        const query = searchParams.toString()
        return api.get<OptionStrategyPosition[]>(`/positions/options${query ? `?${query}` : ""}`)
      },
    }),
}
