module Enums
  module Trades
    class TradeType < T::Enum
      enums do
        Stock  = new("stock")
        Option = new("option")
      end
    end

    class SideType < T::Enum
      enums do
        Buy  = new("buy")
        Sell = new("sell")
      end
    end

    class ActionType < T::Enum
      enums do
        Open  = new("open")
        Close = new("close")
      end
    end

    class OptionType < T::Enum
      enums do
        Call = new("call")
        Put  = new("put")
      end
    end

    class LegSide < T::Enum
      enums do
        Long  = new("long")
        Short = new("short")
      end
    end

    class PositionStatus < T::Enum
      enums do
        Open   = new("open")
        Closed = new("closed")
      end
    end
  end
end
