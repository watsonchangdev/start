import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { TooltipProvider } from "@/components/ui/tooltip";
import { Hash, Menu } from "lucide-react";
import { Sidebar } from "@/components/chat/Sidebar";
import type { SidebarProps } from "@/components/chat/Sidebar";
import { ShowChannel } from "@/components/chat/ShowChannel";
import { channelQueries } from "@/queries/channel-queries";

function ChannelContentSkeleton() {
  return (
    <div className="flex flex-col flex-1 min-w-0 animate-pulse">
      <div className="flex items-center px-4 h-14 border-b shrink-0 gap-2">
        <div className="h-4 w-4 rounded bg-muted" />
        <div className="h-3 w-28 rounded bg-muted" />
      </div>
      <div className="flex-1 px-4 pt-8 space-y-6">
        {[1, 2, 3].map((i) => (
          <div key={i} className="flex gap-3">
            <div className="h-9 w-9 rounded-full bg-muted shrink-0" />
            <div className="space-y-2 flex-1 pt-1">
              <div className="h-3 w-24 rounded bg-muted" />
              <div className="h-3 w-2/3 rounded bg-muted" />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function NoChannelState() {
  return (
    <div className="flex flex-col flex-1 items-center justify-center gap-3 text-muted-foreground">
      <Hash className="h-10 w-10 opacity-20" />
      <p className="text-sm">No channels available.</p>
    </div>
  );
}

export default function Home(props) {
  const [activeChannelUuid, setActiveChannelUuid] = useState<string | null>(null);

  const { data: channels = [], isPending: channelsPending, isError: channelsError } =
    useQuery(channelQueries.list());

  const currentChannel = channels.find((c) => c.uuid === activeChannelUuid) ?? channels[0];

  const sidebarProps: SidebarProps = {
    channels,
    activeChannelUuid: activeChannelUuid ?? currentChannel?.uuid ?? null,
    isPending: channelsPending,
    isError: channelsError,
    onSelectChannel: setActiveChannelUuid,
  };

  console.log(props);

  return (
    <TooltipProvider delay={300}>
      <div className="flex h-screen overflow-hidden">
        <aside className="hidden md:flex w-60 shrink-0 flex-col">
          <Sidebar {...sidebarProps} />
        </aside>

        {channelsPending ? (
          <ChannelContentSkeleton />
        ) : !currentChannel ? (
          <NoChannelState />
        ) : (
          <div className="flex flex-col flex-1 min-w-0">
            <header className="flex items-center justify-between px-4 h-14 border-b shrink-0 bg-background">
              <div className="flex items-center gap-2">
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
                  <span className="font-semibold text-sm">Something inspirational here...</span>
                </div>
              </div>

              <div className="relative">
                <Avatar className="h-8 w-8 cursor-pointer">
                  <AvatarFallback className="text-xs bg-indigo-600 text-white">YO</AvatarFallback>
                </Avatar>
                <span className="absolute -bottom-0.5 -right-0.5 h-2.5 w-2.5 rounded-full bg-green-500 border-2 border-background" />
              </div>
            </header>

            <ShowChannel channel={currentChannel} />
          </div>
        )}
      </div>
    </TooltipProvider>
  );
}
