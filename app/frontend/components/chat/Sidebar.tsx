import { useState } from "react";
import { router, usePage } from "@inertiajs/react";
import type { SharedProps } from "@/types";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";
import { AlertCircle, Hash, LogOut, Plus, Settings } from "lucide-react";
import type { Channel, ChannelType } from "@/types/channel";
import { AddChannelDialog } from "@/components/chat/AddChannelDialog";

export interface SidebarProps {
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

interface ChannelGroupProps {
  label: string;
  channels: Channel[];
  activeChannelUuid: string | null;
  onSelectChannel: (uuid: string) => void;
  onAdd: () => void;
}

function ChannelGroup({ label, channels, activeChannelUuid, onSelectChannel, onAdd }: ChannelGroupProps) {
  return (
    <div className="px-2 mb-3">
      <div className="flex items-center justify-between px-2 py-1 mb-0.5">
        <span className="text-[11px] font-semibold text-zinc-500 uppercase tracking-widest">
          {label}
        </span>
        <Tooltip>
          <TooltipTrigger
            render={
              <Button
                variant="ghost"
                size="icon"
                className="h-5 w-5 text-zinc-500 hover:text-white hover:bg-white/10"
                onClick={onAdd}
              />
            }
          >
            <Plus className="h-3 w-3" />
          </TooltipTrigger>
          <TooltipContent>Add {label.toLowerCase()} channel</TooltipContent>
        </Tooltip>
      </div>

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
  );
}

const GROUPS: { label: string; type: ChannelType }[] = [
  { label: "Features", type: "feature" },
  { label: "Tickers", type: "ticker" }
];

export function Sidebar({ channels, activeChannelUuid, isPending, isError, onSelectChannel }: SidebarProps) {
  const [addChannelType, setAddChannelType] = useState<ChannelType | null>(null);

  return (
    <div className="flex flex-col h-full bg-[#1a1d21] text-zinc-300">
      <div className="flex items-center px-4 py-3 border-b border-white/10">
        <span className="font-semibold text-white text-sm tracking-tight">Underdog Exchange</span>
      </div>

      <ScrollArea className="flex-1 py-3">
        {isPending && <ChannelSkeleton />}

        {isError && (
          <div className="flex items-center gap-2 px-4 py-2 text-red-400 text-xs">
            <AlertCircle className="h-3.5 w-3.5 shrink-0" />
            <span>Failed to load channels</span>
          </div>
        )}

        {!isPending && !isError && GROUPS.map(({ label, type }) => (
          <ChannelGroup
            key={type}
            label={label}
            channels={channels.filter((c) => c.channel_type === type)}
            activeChannelUuid={activeChannelUuid}
            onSelectChannel={onSelectChannel}
            onAdd={() => setAddChannelType(type)}
          />
        ))}
      </ScrollArea>

      <div className="border-t border-white/10 p-3 flex items-center gap-2.5">
        <div className="relative shrink-0">
          <Avatar className="h-8 w-8">
            <AvatarFallback className="text-xs bg-indigo-600 text-white">YO</AvatarFallback>
          </Avatar>
          <span className="absolute -bottom-0.5 -right-0.5 h-2.5 w-2.5 rounded-full bg-green-500 border-2 border-[#1a1d21]" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-medium text-white truncate leading-tight">{usePage<SharedProps>().props.user?.username ?? "—"}</p>
          <p className="text-xs text-zinc-500 truncate leading-tight">Active</p>
        </div>
        <Popover>
          <PopoverTrigger
            render={
              <Button
                variant="ghost"
                size="icon"
                className="h-7 w-7 text-zinc-500 hover:text-white hover:bg-white/10 shrink-0"
              />
            }
          >
            <Settings className="h-4 w-4" />
          </PopoverTrigger>
          <PopoverContent
            side="top"
            align="end"
            className="w-44 rounded-lg p-1 bg-[#1a1d21] border border-white/10 shadow-xl"
          >
            <button
              className="w-full flex items-center gap-2.5 px-2.5 py-2 rounded-md text-sm text-zinc-300 hover:bg-white/[0.08] hover:text-white transition-colors"
            >
              <Settings className="h-4 w-4 opacity-70" />
              Settings
            </button>
            <button
              onClick={() => router.delete("/session")}
              className="w-full flex items-center gap-2.5 px-2.5 py-2 rounded-md text-sm text-zinc-300 hover:bg-white/[0.08] hover:text-white transition-colors"
            >
              <LogOut className="h-4 w-4 opacity-70" />
              Logout
            </button>
          </PopoverContent>
        </Popover>
      </div>

      {addChannelType && (
        <AddChannelDialog
          open={true}
          channelType={addChannelType}
          onOpenChange={(open) => { if (!open) setAddChannelType(null); }}
          onCreated={(channel) => {
            onSelectChannel(channel.uuid);
            setAddChannelType(null);
          }}
        />
      )}
    </div>
  );
}
