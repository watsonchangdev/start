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
  end
end
