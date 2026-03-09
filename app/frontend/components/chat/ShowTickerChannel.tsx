import { useEffect, useRef, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ScrollArea } from "@/components/ui/scroll-area";
import { AlertCircle, BarChart2, Loader2, Send, TrendingDown, TrendingUp, Activity } from "lucide-react";
import { channelMessageMutations, channelMessageQueries } from "@/queries/channel-message-queries";
import { keys } from "@/lib/query-keys";
import type { Channel } from "@/types/channel";
import { ChannelMessageBubble } from "@/components/chat/ChannelMessageBubble";

function MessagesSkeleton() {
  return (
    <div className="px-5 space-y-4 pt-4">
      {[1, 2, 3].map((i) => (
        <div key={i} className="flex gap-3">
          <div className="h-9 w-9 rounded-full bg-muted animate-pulse shrink-0" />
          <div className="space-y-2 flex-1">
            <div className="h-3 w-24 rounded bg-muted animate-pulse" />
            <div className="h-3 w-3/4 rounded bg-muted animate-pulse" />
          </div>
        </div>
      ))}
    </div>
  );
}

export function ShowTickerChannel({ channel }: { channel: Channel }) {
  const [draft, setDraft] = useState("");
  const bottomRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const queryClient = useQueryClient();

  const {
    data: messages = [],
    isPending: messagesPending,
    isError: messagesError,
  } = useQuery(channelMessageQueries.list(channel.uuid));

  const { mutate: sendMessage, isPending: sending } = useMutation({
    ...channelMessageMutations.create(channel.uuid),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: keys.channels.messages(channel.uuid) });
    },
  });

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, channel.uuid]);

  useEffect(() => {
    inputRef.current?.focus();
  }, [channel.uuid]);

  function handleSend() {
    const content = draft.trim();
    if (!content || sending) return;
    setDraft("");
    sendMessage({ content }, { onSettled: () => inputRef.current?.focus() });
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  }

  return (
    <div className="flex flex-col flex-1 min-h-0">
      <div className="shrink-0 px-4 pt-8 pb-4 border-b bg-background">
        <div className="flex items-center gap-2 mb-1">
          <BarChart2 className="h-6 w-6" />
          <h2 className="text-xl font-bold">{channel.name}</h2>
        </div>
        <div className="flex items-stretch gap-2 mt-3">
          <div className="flex-1 rounded-lg border bg-muted/20 px-3 py-2.5">
            <p className="text-[11px] text-muted-foreground mb-1">Price</p>
            <p className="text-base font-semibold tabular-nums">$213.49</p>
          </div>
          <div className="flex-1 rounded-lg border bg-muted/20 px-3 py-2.5">
            <p className="text-[11px] text-muted-foreground mb-1">Today</p>
            <div className="flex items-center gap-1">
              <TrendingUp className="h-4 w-4 text-green-600 shrink-0" />
              <p className="text-base font-semibold tabular-nums text-green-600">+$3.21</p>
            </div>
            <p className="text-[11px] text-green-600 tabular-nums">+1.53%</p>
          </div>
          <div className="flex-1 rounded-lg border bg-muted/20 px-3 py-2.5">
            <p className="text-[11px] text-muted-foreground mb-1">Volume</p>
            <div className="flex items-center gap-1">
              <Activity className="h-4 w-4 text-orange-500 shrink-0" />
              <p className="text-base font-semibold tabular-nums">84.2M</p>
            </div>
            <p className="text-[11px] text-orange-500">irregular</p>
          </div>
          <div className="flex-1 rounded-lg border bg-muted/20 px-3 py-2.5">
            <p className="text-[11px] text-muted-foreground mb-1">My P&L</p>
            <p className="text-base font-semibold tabular-nums text-green-600">+$1,240.00</p>
            <p className="text-[11px] text-muted-foreground tabular-nums">Day <span className="text-green-600 font-medium">+$318.50</span></p>
          </div>
        </div>
      </div>

      <ScrollArea className="flex-1 min-h-0">
        <div className="px-4 pb-4">
          {messagesPending && <MessagesSkeleton />}

          {messagesError && (
            <div className="flex items-center gap-2 px-1 py-4 text-red-500 text-sm">
              <AlertCircle className="h-4 w-4 shrink-0" />
              <span>Failed to load messages.</span>
            </div>
          )}

          {!messagesPending && !messagesError && messages.length === 0 && (
            <div className="flex flex-col items-center justify-center py-12 text-muted-foreground">
              <p className="text-sm">No activity yet.</p>
            </div>
          )}

          {messages.map((msg) => (
            <ChannelMessageBubble key={msg.uuid} message={msg} />
          ))}

          <div ref={bottomRef} />
        </div>
      </ScrollArea>

      <div className="px-4 pb-4 pt-2 shrink-0 bg-background">
        <div className="flex items-center gap-2 border rounded-lg px-3 py-2 focus-within:ring-1 focus-within:ring-ring transition-shadow">
          <Input
            ref={inputRef}
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder={`Message #${channel.name}`}
            className="border-0 shadow-none p-0 focus-visible:ring-0 text-sm h-auto bg-transparent"
            disabled={sending}
          />
          <Button
            size="icon"
            variant={draft.trim() ? "default" : "ghost"}
            className="h-7 w-7 shrink-0 transition-all"
            onClick={handleSend}
            disabled={!draft.trim() || sending}
          >
            {sending ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : (
              <Send className="h-3.5 w-3.5" />
            )}
          </Button>
        </div>
        <p className="text-xs text-muted-foreground mt-1.5 px-1">
          Press <kbd className="px-1 py-0.5 bg-muted rounded text-[11px] font-mono">Enter</kbd> to send
        </p>
      </div>
    </div>
  );
}
