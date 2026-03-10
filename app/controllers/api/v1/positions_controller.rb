class Api::V1::PositionsController < Api::V1::BaseController
  def options
    option_positions = current_user.option_positions
      .includes(:ticker, option_contract: [ :minute_prices, :daily_prices ])

    option_positions = option_positions.joins(:ticker).where(ticker: { symbol: params[:symbol].upcase }) if params[:symbol].present?

    positions = PositionService.get_realtime_option_positions(option_positions)
    positions = positions.select { |p| p.status == Enums::Trades::PositionStatus::Open } if filter_open_only?

    render json: OptionPositionResource.new(positions).serialize
  end

  private

  def filter_open_only?
    params[:status].blank? || params[:status] == "open"
  end
end
