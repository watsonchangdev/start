import { useEffect, useRef, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ScrollArea } from "@/components/ui/scroll-area";
import { AlertCircle, Hash, Loader2, Send } from "lucide-react";
import { channelMessageMutations, channelMessageQueries } from "@/queries/channel-message-queries";
import { keys } from "@/lib/query-keys";
import type { Channel } from "@/types/channel";
import type { ChannelMessage } from "@/types/channel-message";

// --- Helpers ---

function initials(name: string) {
  return name
    .split(" ")
    .map((w) => w[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

function formatTime(iso: string) {
  return new Date(iso).toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
}

// --- Message Bubble ---

interface MessageBubbleProps {
  message: ChannelMessage;
}

function MessageBubble({ message }: MessageBubbleProps) {
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
        <div className="flex items-baseline gap-2 mb-0.5">
          <span className="text-sm font-semibold leading-none text-foreground">
            {message.username}
          </span>
          <span className="text-xs text-muted-foreground">{formatTime(message.created_at)}</span>
        </div>
        <p className="text-sm text-foreground leading-relaxed">{message.content}</p>
      </div>
    </div>
  );
}

// --- Messages Skeleton ---

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

// --- ShowChannel ---

export interface ShowChannelProps {
  channel: Channel;
}

export function ShowChannel({ channel }: ShowChannelProps) {
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
      {/* Messages */}
      <ScrollArea className="flex-1 min-h-0">
        <div className="px-4 pb-4">
          <div className="pt-8 pb-4 mb-2 border-b">
            <div className="flex items-center gap-2 mb-1">
              <Hash className="h-6 w-6" />
              <h2 className="text-xl font-bold">{channel.name}</h2>
            </div>
            <p className="text-sm text-muted-foreground">
              This is the beginning of the <strong>#{channel.name}</strong> channel.
            </p>
          </div>

          {messagesPending && <MessagesSkeleton />}

          {messagesError && (
            <div className="flex items-center gap-2 px-1 py-4 text-red-500 text-sm">
              <AlertCircle className="h-4 w-4 shrink-0" />
              <span>Failed to load messages.</span>
            </div>
          )}

          {!messagesPending && !messagesError && messages.length === 0 && (
            <div className="flex flex-col items-center justify-center py-12 text-muted-foreground">
              <p className="text-sm">No messages yet. Say hello!</p>
            </div>
          )}

          {messages.map((msg) => (
            <MessageBubble key={msg.uuid} message={msg} />
          ))}

          <div ref={bottomRef} />
        </div>
      </ScrollArea>

      {/* Message input */}
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
