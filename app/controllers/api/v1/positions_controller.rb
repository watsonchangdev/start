class Api::V1::PositionsController < Api::V1::BaseController
  def options
    trades = current_user.trades
      .where(trade_type: "option")
      .includes(option_legs: { option_contract: [ :minute_prices, :daily_prices ] }, ticker: [])

    trades = trades.joins(:ticker).where(ticker: { symbol: params[:symbol].upcase }) if params[:symbol].present?

    positions = OptionsPositionService.get_realtime_option_positions(trades)
    positions = positions.select { |p| p.status == Enums::Trades::PositionStatus::Open } if filter_open_only?

    render json: OptionPositionResource.new(positions).serialize
  end

  private

  def filter_open_only?
    params[:status].blank? || params[:status] == "open"
  end
end
