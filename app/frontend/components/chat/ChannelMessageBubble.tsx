import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { ExternalLink } from "lucide-react";
import type { ChannelMessage, DataTableMetadata, MediaLinkMetadata, OptionStrategyPosition } from "@/types/channel-message";

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

function formatPnl(value: number) {
  const formatted = new Intl.NumberFormat("en-US", { style: "currency", currency: "USD", signDisplay: "always" }).format(value);
  return { formatted, positive: value >= 0 };
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

function OptionPositionCard({ position }: { position: OptionStrategyPosition }) {
  const netPnl = position.net_realized_pnl + position.net_unrealized_pnl;
  const pnl = formatPnl(netPnl);

  return (
    <div className="rounded-lg border bg-muted/20 overflow-hidden">
      <div className="flex items-center justify-between px-3 py-2 border-b bg-muted/30">
        <div className="flex items-center gap-2">
          <span className="text-sm font-bold">{position.symbol}</span>
          <span className="text-xs text-muted-foreground">@ {formatPrice(position.spot_price)}</span>
        </div>
        <span className={`text-xs font-medium tabular-nums ${pnl.positive ? "text-green-600" : "text-red-500"}`}>
          {pnl.formatted}
        </span>
      </div>

      <table className="w-full text-xs">
        <thead>
          <tr className="text-muted-foreground border-b">
            <th className="text-left font-medium px-3 py-1.5">Contract</th>
            <th className="text-center font-medium px-2 py-1.5">Side</th>
            <th className="text-right font-medium px-2 py-1.5">Qty</th>
            <th className="text-right font-medium px-2 py-1.5">Strike</th>
            <th className="text-right font-medium px-2 py-1.5">Exp</th>
            <th className="text-right font-medium px-2 py-1.5">Trade</th>
            <th className="text-right font-medium px-2 py-1.5">Mark</th>
            <th className="text-right font-medium px-3 py-1.5">P&L</th>
          </tr>
        </thead>
        <tbody>
          {position.legs.map((leg) => {
            const legPnl = formatPnl(leg.unrealized_pnl + leg.realized_pnl);
            return (
              <tr key={leg.occ_symbol} className="border-b last:border-0">
                <td className="px-3 py-1.5 font-mono text-[11px]">{leg.occ_symbol}</td>
                <td className="px-2 py-1.5 text-center">
                  <span className={`capitalize ${leg.side === "long" ? "text-blue-600" : "text-orange-500"}`}>
                    {leg.side}
                  </span>
                </td>
                <td className="px-2 py-1.5 text-right tabular-nums">{leg.quantity}</td>
                <td className="px-2 py-1.5 text-right tabular-nums">{formatPrice(leg.strike_price)}</td>
                <td className="px-2 py-1.5 text-right tabular-nums">{leg.expiration_date}</td>
                <td className="px-2 py-1.5 text-right tabular-nums">{formatPrice(leg.trade_price)}</td>
                <td className="px-2 py-1.5 text-right tabular-nums">{formatPrice(leg.mark_price)}</td>
                <td className={`px-3 py-1.5 text-right tabular-nums font-medium ${legPnl.positive ? "text-green-600" : "text-red-500"}`}>
                  {legPnl.formatted}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}

function DataTableBody({ metadata }: { metadata: DataTableMetadata }) {
  const positions = metadata.data;

  if (positions.length === 0) {
    return <p className="text-sm text-muted-foreground italic">No open positions.</p>;
  }

  return (
    <div className="space-y-3 max-w-2xl">
      {positions.map((position) => (
        <OptionPositionCard key={position.symbol} position={position} />
      ))}
    </div>
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
        ) : message.message_type === "data_table" ? (
          <DataTableBody metadata={message.metadata} />
        ) : message.message_type === "notification" ? (
          <NotificationBody content={message.content} />
        ) : (
          <UserMessageBody content={message.content} />
        )}
      </div>
    </div>
  );
}
