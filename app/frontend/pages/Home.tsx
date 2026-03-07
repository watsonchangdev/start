import { useEffect, useRef, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { AlertCircle, Hash, Loader2, Menu, Plus, Send, Settings } from "lucide-react";
import { channelQueries } from "@/queries/channel-queries";
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

// --- Sidebar ---

interface SidebarProps {
  channels: Channel[];
  activeChannelUuid: string | null;
  isPending: boolean;
  isError: boolean;
  onSelectChannel: (uuid: string) => void;
}

function ChannelSkeleton() {
  return (
    <div className="px-4 space-y-1.5 py-1">
      {[40, 64, 52, 48, 72].map((w) => (
        <div key={w} className="flex items-center gap-2 py-1">
          <div className="h-4 w-4 rounded bg-white/10 shrink-0 animate-pulse" />
          <div className="h-3 rounded bg-white/10 animate-pulse" style={{ width: w }} />
        </div>
      ))}
    </div>
  );
}

function Sidebar({ channels, activeChannelUuid, isPending, isError, onSelectChannel }: SidebarProps) {
  return (
    <div className="flex flex-col h-full bg-[#1a1d21] text-zinc-300">
      <div className="flex items-center px-4 py-3 border-b border-white/10">
        <span className="font-semibold text-white text-sm tracking-tight">UnderDog Exchange</span>
      </div>

      <ScrollArea className="flex-1 py-3">
        <div className="px-2 mb-1">
          <div className="flex items-center justify-between px-2 py-1 mb-0.5">
            <span className="text-[11px] font-semibold text-zinc-500 uppercase tracking-widest">
              Channels
            </span>
            <Tooltip>
              <TooltipTrigger
                render={
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-5 w-5 text-zinc-500 hover:text-white hover:bg-white/10"
                  />
                }
              >
                <Plus className="h-3 w-3" />
              </TooltipTrigger>
              <TooltipContent>Add channel</TooltipContent>
            </Tooltip>
          </div>

          {isPending && <ChannelSkeleton />}

          {isError && (
            <div className="flex items-center gap-2 px-2 py-2 text-red-400 text-xs">
              <AlertCircle className="h-3.5 w-3.5 shrink-0" />
              <span>Failed to load channels</span>
            </div>
          )}

          {channels.map((channel) => (
            <button
              key={channel.uuid}
              onClick={() => onSelectChannel(channel.uuid)}
              className={cn(
                "w-full flex items-center gap-2 px-2 py-1.5 rounded-md text-sm transition-colors text-left",
                activeChannelUuid === channel.uuid
                  ? "bg-white/15 text-white"
                  : "text-zinc-400 hover:bg-white/[0.08] hover:text-zinc-100"
              )}
            >
              <Hash className="h-4 w-4 shrink-0 opacity-70" />
              <span className="flex-1 truncate">{channel.name}</span>
            </button>
          ))}
        </div>
      </ScrollArea>

      <div className="border-t border-white/10 p-3 flex items-center gap-2.5">
        <div className="relative shrink-0">
          <Avatar className="h-8 w-8">
            <AvatarFallback className="text-xs bg-indigo-600 text-white">YO</AvatarFallback>
          </Avatar>
          <span className="absolute -bottom-0.5 -right-0.5 h-2.5 w-2.5 rounded-full bg-green-500 border-2 border-[#1a1d21]" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-medium text-white truncate leading-tight">You</p>
          <p className="text-xs text-zinc-500 truncate leading-tight">Active</p>
        </div>
        <Tooltip>
          <TooltipTrigger
            render={
              <Button
                variant="ghost"
                size="icon"
                className="h-7 w-7 text-zinc-500 hover:text-white hover:bg-white/10 shrink-0"
              />
            }
          >
            <Settings className="h-4 w-4" />
          </TooltipTrigger>
          <TooltipContent>Preferences</TooltipContent>
        </Tooltip>
      </div>
    </div>
  );
}

// --- Message Bubble ---

interface MessageBubbleProps {
  message: ChannelMessage;
  isGrouped: boolean;
}

function MessageBubble({ message, isGrouped }: MessageBubbleProps) {
  return (
    <div className={cn("flex gap-3 px-1", isGrouped ? "mt-0.5" : "mt-4")}>
      <div className="w-9 shrink-0 pt-0.5">
        {!isGrouped && (
          <Avatar className="h-9 w-9">
            <AvatarFallback className="text-xs font-medium bg-zinc-200 text-zinc-700">
              {initials(message.username)}
            </AvatarFallback>
          </Avatar>
        )}
      </div>

      <div className="flex-1 min-w-0">
        {!isGrouped && (
          <div className="flex items-baseline gap-2 mb-0.5">
            <span className="text-sm font-semibold leading-none text-foreground">
              {message.username}
            </span>
            <span className="text-xs text-muted-foreground">{formatTime(message.created_at)}</span>
          </div>
        )}
        <p className="text-sm text-foreground leading-relaxed">{message.content}</p>
      </div>
    </div>
  );
}

// --- Messages area ---

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

// --- Page ---

export default function Home() {
  const [activeChannelUuid, setActiveChannelUuid] = useState<string | null>(null);
  const [draft, setDraft] = useState("");
  const bottomRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const queryClient = useQueryClient();

  const { data: channels = [], isPending: channelsPending, isError: channelsError } =
    useQuery(channelQueries.list());

  // Default to the first channel; respect explicit selection thereafter
  const currentChannel = channels.find((c) => c.uuid === activeChannelUuid) ?? channels[0];
  const channelUuid = currentChannel?.uuid ?? "";

  const {
    data: messages = [],
    isPending: messagesPending,
    isError: messagesError,
  } = useQuery(channelMessageQueries.list(channelUuid));

  const { mutate: sendMessage, isPending: sending } = useMutation({
    ...channelMessageMutations.create(channelUuid),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: keys.channels.messages(channelUuid) });
    },
  });

  // Scroll to bottom whenever messages change or channel switches
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, channelUuid]);

  // Focus input on mount and when switching channels
  useEffect(() => {
    inputRef.current?.focus();
  }, [channelUuid]);

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

  const sidebarProps: SidebarProps = {
    channels,
    activeChannelUuid: activeChannelUuid ?? currentChannel?.uuid ?? null,
    isPending: channelsPending,
    isError: channelsError,
    onSelectChannel: setActiveChannelUuid,
  };

  return (
    <TooltipProvider delay={300}>
      <div className="flex h-screen overflow-hidden">
        {/* Desktop sidebar */}
        <aside className="hidden md:flex w-60 shrink-0 flex-col">
          <Sidebar {...sidebarProps} />
        </aside>

        {/* Main area */}
        <div className="flex flex-col flex-1 min-w-0">
          {/* Header */}
          <header className="flex items-center justify-between px-4 h-14 border-b shrink-0 bg-background">
            <div className="flex items-center gap-2">
              {/* Mobile sidebar trigger */}
              <Sheet>
                <SheetTrigger
                  render={
                    <Button variant="ghost" size="icon" className="md:hidden -ml-1" />
                  }
                >
                  <Menu className="h-5 w-5" />
                </SheetTrigger>
                <SheetContent side="left" className="p-0 w-60 border-0">
                  <Sidebar {...sidebarProps} />
                </SheetContent>
              </Sheet>

              <div className="flex items-center gap-1.5">
                <Hash className="h-4 w-4 text-muted-foreground" />
                <span className="font-semibold text-sm">{currentChannel?.name}</span>
              </div>
            </div>

            <div className="relative">
              <Avatar className="h-8 w-8 cursor-pointer">
                <AvatarFallback className="text-xs bg-indigo-600 text-white">YO</AvatarFallback>
              </Avatar>
              <span className="absolute -bottom-0.5 -right-0.5 h-2.5 w-2.5 rounded-full bg-green-500 border-2 border-background" />
            </div>
          </header>

          {/* Messages */}
          <ScrollArea className="flex-1">
            <div className="px-4 pb-4">
              {/* Channel intro */}
              <div className="pt-8 pb-4 mb-2 border-b">
                <div className="flex items-center gap-2 mb-1">
                  <Hash className="h-6 w-6" />
                  <h2 className="text-xl font-bold">{currentChannel?.name}</h2>
                </div>
                <p className="text-sm text-muted-foreground">
                  This is the beginning of the <strong>#{currentChannel?.name}</strong> channel.
                </p>
              </div>

              {messagesPending && <MessagesSkeleton />}

              {messagesError && (
                <div className="flex items-center gap-2 px-1 py-4 text-red-500 text-sm">
                  <AlertCircle className="h-4 w-4 shrink-0" />
                  <span>Failed to load messages.</span>
                </div>
              )}

              {messages.map((msg, i) => {
                const isGrouped = i > 0 && messages[i - 1].username === msg.username;
                return <MessageBubble key={msg.uuid} message={msg} isGrouped={isGrouped} />;
              })}

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
                placeholder={`Message #${currentChannel?.name}`}
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
      </div>
    </TooltipProvider>
  );
}
