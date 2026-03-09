class Api::V1::PositionsController < Api::V1::BaseController
  def option_positions
    trades = current_user.trades.option.includes(option_legs: :option_contract)

    trades = trades.select { |t| t.option_legs.any? { |l| l.action_type == "open" } } if filter_open_only?

    if params[:symbol].present?
      trades = trades.select { |t| t.ticker.symbol.upcase == params[:symbol].upcase }
    end

    if params[:expires_within_days].present?
      cutoff = Date.today + params[:expires_within_days].to_i.days
      trades = trades.select do |t|
        t.option_legs.any? { |l| l.option_contract.expires_on <= cutoff }
      end
    end

    positions = trades.map { |t| OptionsPositionService.get_realtime_option_position(t) }

    render json: OptionPositionResource.new(positions).serialize
  end

  private

  def filter_open_only?
    params[:status].blank? || params[:status] == "open"
  end
end
