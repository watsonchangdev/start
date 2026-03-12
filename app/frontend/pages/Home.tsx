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

function WalkingDog() {
  return (
    <>
      <style>{`
        @keyframes eskie-pace {
          0%   { transform: translateX(-250px); }
          100% { transform: translateX(250px); }
        }
        @keyframes eskie-bob {
          0%, 100% { transform: translateY(0px); }
          50%       { transform: translateY(-2px); }
        }
        @keyframes eskie-tail {
          0%, 100% { transform: rotate(-12deg); }
          50%       { transform: rotate(12deg); }
        }
        @keyframes eskie-leg-a {
          0%, 100% { transform: rotate(20deg); }
          50%       { transform: rotate(-20deg); }
        }
        @keyframes eskie-leg-b {
          0%, 100% { transform: rotate(-20deg); }
          50%       { transform: rotate(20deg); }
        }
        @keyframes eskie-blink {
          0%, 88%, 100% { transform: scaleY(1); }
          92%            { transform: scaleY(0.08); }
        }
        .eskie-pace { animation: eskie-pace 9s ease-in-out infinite alternate; }
        .eskie-bob  { animation: eskie-bob 0.9s ease-in-out infinite; }
        .eskie-tail { transform-box: fill-box; transform-origin: left bottom; animation: eskie-tail 0.9s ease-in-out infinite; }
        .eskie-fl1  { transform-box: fill-box; transform-origin: center top; animation: eskie-leg-a 0.9s ease-in-out infinite; }
        .eskie-fl2  { transform-box: fill-box; transform-origin: center top; animation: eskie-leg-b 0.9s ease-in-out infinite; }
        .eskie-bl1  { transform-box: fill-box; transform-origin: center top; animation: eskie-leg-b 0.9s ease-in-out infinite; }
        .eskie-bl2  { transform-box: fill-box; transform-origin: center top; animation: eskie-leg-a 0.9s ease-in-out infinite; }
        .eskie-eye  { transform-box: fill-box; transform-origin: center center; animation: eskie-blink 5s ease-in-out infinite; }
      `}</style>
      <div className="overflow-hidden w-[640px] h-[72px] flex items-center justify-center">
        <div className="eskie-pace">
          <svg width="104" height="70" viewBox="0 -6 104 72">
            <g className="eskie-bob">

              {/* fluffy tail — layered strokes for volume */}
              <g className="eskie-tail">
                <path d="M17,34 C5,22 2,7 12,2 C20,-2 30,5 25,17 C21,25 15,29 17,33"
                      fill="none" stroke="#e8ddd0" strokeWidth="14" strokeLinecap="round" strokeLinejoin="round"/>
                <path d="M17,34 C5,22 2,7 12,2 C20,-2 30,5 25,17 C21,25 15,29 17,33"
                      fill="none" stroke="#faf8f4" strokeWidth="8" strokeLinecap="round" strokeLinejoin="round"/>
                <path d="M17,34 C5,22 2,7 12,2 C20,-2 30,5 25,17 C21,25 15,29 17,33"
                      fill="none" stroke="#f0ebe3" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" strokeDasharray="2 4"/>
              </g>

              {/* body */}
              <ellipse cx="39" cy="39" rx="25" ry="13" fill="#faf8f4"/>

              {/* neck */}
              <ellipse cx="58" cy="31" rx="10" ry="9" fill="#faf8f4"/>

              {/* head — big for anime cuteness */}
              <circle cx="70" cy="19" r="16" fill="#faf8f4"/>

              {/* back ear outer */}
              <polygon points="61,10 68,10 63,-2" fill="#f0ebe3"/>
              {/* back ear inner pink */}
              <polygon points="62.5,9 67,9 63.5,1" fill="#ffd6e4"/>

              {/* front ear outer */}
              <polygon points="69,8 78,8 75,-3" fill="#faf8f4"/>
              {/* front ear inner pink */}
              <polygon points="70.5,7 76.5,7 74.5,0" fill="#ffd6e4"/>

              {/* muzzle — stout */}
              <ellipse cx="86" cy="24" rx="9" ry="5.5" fill="#f0ebe3"/>

              {/* blush cheeks */}
              <ellipse cx="80" cy="27" rx="5" ry="3" fill="#ffb3c6" fillOpacity="0.45"/>

              {/* anime eye */}
              <g className="eskie-eye">
                <ellipse cx="74" cy="17" rx="5.5" ry="6" fill="#2a1a0e"/>
                {/* iris */}
                <ellipse cx="74" cy="17.5" rx="3.5" ry="4" fill="#8b5e3c"/>
                {/* pupil */}
                <ellipse cx="74" cy="18" rx="2" ry="2.5" fill="#2a1a0e"/>
                {/* large shine */}
                <circle cx="76.5" cy="14" r="2.2" fill="white"/>
                {/* small shine */}
                <circle cx="71.5" cy="20" r="1.1" fill="white" fillOpacity="0.8"/>
              </g>

              {/* cute pink nose */}
              <ellipse cx="94" cy="22" rx="2.8" ry="2.2" fill="#1a1008"/>

              {/* front legs — short and stubby */}
              <rect className="eskie-fl1" x="52" y="50" width="9" height="15" rx="4.5" fill="#faf8f4"/>
              <rect className="eskie-fl2" x="62" y="50" width="9" height="15" rx="4.5" fill="#f0ebe3"/>

              {/* back legs */}
              <rect className="eskie-bl1" x="21" y="50" width="9" height="15" rx="4.5" fill="#faf8f4"/>
              <rect className="eskie-bl2" x="31" y="50" width="9" height="15" rx="4.5" fill="#f0ebe3"/>

            </g>
          </svg>
        </div>
      </div>
    </>
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

                <WalkingDog />
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
