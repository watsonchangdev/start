import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { ExternalLink } from "lucide-react";
import type { ChannelMessage, MediaLinkMetadata } from "@/types/channel-message";

// --- Helpers ---

function initials(name: string) {
  return name.split(" ").map((w) => w[0]).join("").toUpperCase().slice(0, 2);
}

function formatTime(iso: string) {
  return new Date(iso).toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
}

function formatPrice(price: number | null) {
  if (price == null) return null;
  return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(price);
}

// --- Message body variants ---

function UserMessageBody({ content }: { content: string }) {
  return <p className="text-sm text-foreground leading-relaxed">{content}</p>;
}

function MediaLinkBody({ content, metadata }: { content: string; metadata: MediaLinkMetadata }) {
  return (
    <a
      href={metadata.source_url}
      target="_blank"
      rel="noopener noreferrer"
      className="group block rounded-lg border bg-muted/40 hover:bg-muted transition-colors overflow-hidden max-w-sm"
    >
<div className="p-3 space-y-1">
        <p className="text-sm font-medium leading-snug text-foreground line-clamp-2">{content}</p>
        {metadata.ticker_price != null && (
          <p className="text-xs text-muted-foreground">
            Price at publish: <span className="font-medium text-foreground">{formatPrice(metadata.ticker_price)}</span>
          </p>
        )}
        <div className="flex items-center gap-1 text-xs text-muted-foreground pt-0.5">
          <ExternalLink className="h-3 w-3" />
          <span className="truncate">{new URL(metadata.source_url).hostname}</span>
        </div>
      </div>
    </a>
  );
}

function NotificationBody({ content }: { content: string }) {
  return (
    <p className="text-sm text-muted-foreground italic leading-relaxed">{content}</p>
  );
}

// --- Message Bubble ---

export interface ChannelMessageBubbleProps {
  message: ChannelMessage;
}

export function ChannelMessageBubble({ message }: ChannelMessageBubbleProps) {
  return (
    <div className="flex gap-3 px-1 mt-4">
      <div className="w-9 shrink-0 pt-0.5">
        <Avatar className="h-9 w-9">
          <AvatarFallback className="text-xs font-medium bg-zinc-200 text-zinc-700">
            {initials(message.username)}
          </AvatarFallback>
        </Avatar>
      </div>

      <div className="flex-1 min-w-0">
        <div className="flex items-baseline gap-2 mb-1">
          <span className="text-sm font-semibold leading-none text-foreground">
            {message.username}
          </span>
          <span className="text-xs text-muted-foreground">{formatTime(message.created_at)}</span>
        </div>

        {message.message_type === "media_link" ? (
          <MediaLinkBody content={message.content} metadata={message.metadata} />
        ) : message.message_type === "notification" ? (
          <NotificationBody content={message.content} />
        ) : (
          <UserMessageBody content={message.content} />
        )}
      </div>
    </div>
  );
}
