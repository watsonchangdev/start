class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_user

  inertia_share do
    {
      user: set_user
    }
  end

  private

  def set_user    
    @user ||= if authenticated?
      Current.user
    else
      nil
    end
  end
end
