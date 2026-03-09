import type { Channel } from "@/types/channel";
import { ShowTickerChannel } from "@/components/chat/ShowTickerChannel";
import { ShowChatChannel } from "@/components/chat/ShowChatChannel";
import { ShowFeatureChannel } from "@/components/chat/ShowFeatureChannel";

export interface ShowChannelProps {
  channel: Channel;
}

export function ShowChannel({ channel }: ShowChannelProps) {
  switch (channel.channel_type) {
    case "ticker":
      return <ShowTickerChannel channel={channel} />;
    case "chat":
      return <ShowChatChannel channel={channel} />;
    case "feature":
      return <ShowFeatureChannel channel={channel} />;
  }
}
