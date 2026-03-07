import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { AlertCircle, Bell, Hash, Menu, Plus, Send, Settings } from "lucide-react";
import { channelQueries } from "@/queries/channel-queries";
import type { Channel } from "@/types/channel";

// --- Types ---

interface Message {
  id: string;
  author: string;
  content: string;
  timestamp: string;
  isOwn?: boolean;
}

// --- Mock Data (messages only — channels are live) ---

const MESSAGES: Message[] = [
  {
    id: "1",
    author: "Alice Chen",
    content: "Good morning everyone! Who's up for a quick sync at 10am?",
    timestamp: "9:02 AM",
  },
  {
    id: "2",
    author: "Bob Tanaka",
    content: "I'm in! What's on the agenda?",
    timestamp: "9:04 AM",
  },
  {
    id: "3",
    author: "Alice Chen",
    content: "Sprint planning and a quick review of last week's retro action items.",
    timestamp: "9:05 AM",
  },
  {
    id: "4",
    author: "Carol Smith",
    content: "Sounds good, I'll join too. I have some updates on the design system to share.",
    timestamp: "9:07 AM",
  },
  {
    id: "5",
    author: "You",
    content: "Perfect, I'll send a calendar invite.",
    timestamp: "9:08 AM",
    isOwn: true,
  },
  {
    id: "6",
    author: "Bob Tanaka",
    content: "Thanks! Also just pushed the PR for the auth refactor if anyone has bandwidth to review.",
    timestamp: "9:15 AM",
  },
  {
    id: "7",
    author: "Carol Smith",
    content: "I'll take a look after standup.",
    timestamp: "9:16 AM",
  },
  {
    id: "8",
    author: "You",
    content: "Same here, queuing it up now.",
    timestamp: "9:18 AM",
    isOwn: true,
  },
];

// --- Helpers ---

function initials(name: string) {
  return name
    .split(" ")
    .map((w) => w[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

// --- Sidebar ---

interface SidebarProps {
  channels: Channel[];
  activeChannelId: number | null;
  isPending: boolean;
  isError: boolean;
  onSelectChannel: (id: number) => void;
}

function ChannelSkeleton() {
  return (
    <div className="px-4 space-y-1.5 py-1">
      {[40, 64, 52, 48, 72].map((w) => (
        <div key={w} className="flex items-center gap-2 py-1">
          <div className="h-4 w-4 rounded bg-white/10 shrink-0 animate-pulse" />
          <div className={`h-3 rounded bg-white/10 animate-pulse`} style={{ width: w }} />
        </div>
      ))}
    </div>
  );
}

function Sidebar({ channels, activeChannelId, isPending, isError, onSelectChannel }: SidebarProps) {
  return (
    <div className="flex flex-col h-full bg-[#1a1d21] text-zinc-300">
      {/* Workspace header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-white/10">
        <span className="font-semibold text-white text-sm tracking-tight">UnderDog Exchange</span>
        <Tooltip>
          <TooltipTrigger
            render={
              <Button
                variant="ghost"
                size="icon"
                className="h-7 w-7 text-zinc-400 hover:text-white hover:bg-white/10"
              />
            }
          >
            <Bell className="h-4 w-4" />
          </TooltipTrigger>
          <TooltipContent>Notifications</TooltipContent>
        </Tooltip>
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
              key={channel.id}
              onClick={() => onSelectChannel(channel.id)}
              className={cn(
                "w-full flex items-center gap-2 px-2 py-1.5 rounded-md text-sm transition-colors text-left",
                activeChannelId === channel.id
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

      {/* User profile */}
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
  message: Message;
  isGrouped: boolean;
}

function MessageBubble({ message, isGrouped }: MessageBubbleProps) {
  return (
    <div className={cn("flex gap-3 px-1", isGrouped ? "mt-0.5" : "mt-4")}>
      {/* Fixed-width avatar column keeps all messages aligned */}
      <div className="w-9 shrink-0 pt-0.5">
        {!isGrouped && (
          <Avatar className="h-9 w-9">
            <AvatarFallback
              className={cn(
                "text-xs font-medium",
                message.isOwn ? "bg-indigo-600 text-white" : "bg-zinc-200 text-zinc-700"
              )}
            >
              {initials(message.author)}
            </AvatarFallback>
          </Avatar>
        )}
      </div>

      <div className="flex-1 min-w-0">
        {!isGrouped && (
          <div className="flex items-baseline gap-2 mb-0.5">
            <span
              className={cn(
                "text-sm font-semibold leading-none",
                message.isOwn ? "text-indigo-600" : "text-foreground"
              )}
            >
              {message.author}
            </span>
            <span className="text-xs text-muted-foreground">{message.timestamp}</span>
          </div>
        )}
        <p className="text-sm text-foreground leading-relaxed">{message.content}</p>
      </div>
    </div>
  );
}

// --- Page ---

export default function Home() {
  const [activeChannelId, setActiveChannelId] = useState<number | null>(null);
  const [message, setMessage] = useState("");

  const { data: channels = [], isPending, isError } = useQuery(channelQueries.list());

  // Default to the first channel once loaded; respect explicit selection thereafter
  const currentChannel =
    channels.find((c) => c.id === activeChannelId) ?? channels[0];

  function handleSend() {
    if (!message.trim()) return;
    setMessage("");
    // TODO: send message
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  }

  const sidebarProps: SidebarProps = {
    channels,
    activeChannelId: activeChannelId ?? currentChannel?.id ?? null,
    isPending,
    isError,
    onSelectChannel: setActiveChannelId,
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

            {/* User avatar top-right */}
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

              {MESSAGES.map((msg, i) => {
                const isGrouped = i > 0 && MESSAGES[i - 1].author === msg.author;
                return <MessageBubble key={msg.id} message={msg} isGrouped={isGrouped} />;
              })}
            </div>
          </ScrollArea>

          {/* Message input */}
          <div className="px-4 pb-4 pt-2 shrink-0 bg-background">
            <div className="flex items-center gap-2 border rounded-lg px-3 py-2 focus-within:ring-1 focus-within:ring-ring transition-shadow">
              <Input
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder={`Message #${currentChannel?.name}`}
                className="border-0 shadow-none p-0 focus-visible:ring-0 text-sm h-auto bg-transparent"
              />
              <Button
                size="icon"
                variant={message.trim() ? "default" : "ghost"}
                className="h-7 w-7 shrink-0 transition-all"
                onClick={handleSend}
                disabled={!message.trim()}
              >
                <Send className="h-3.5 w-3.5" />
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
