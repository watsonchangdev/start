module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_api_authentication
  end

  private

  def require_api_authentication
    resume_session || render_unauthorized
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def current_user
    Current.session&.user
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
