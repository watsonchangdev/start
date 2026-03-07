class Api::V1::BaseController < ActionController::Base
  include ApiAuthentication

  protect_from_forgery with: :null_session

  private

  def render_error(message, status:)
    render json: { error: message }, status: status
  end
end
