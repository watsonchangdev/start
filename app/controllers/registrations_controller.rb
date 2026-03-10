class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :redirect_if_authenticated, only: %i[ new create ]

  def new
    render inertia: "auth/Register"
  end

  def create
    user = User.new(registration_params)
    if user.save
      start_new_session_for user
      redirect_to root_path
    else
      redirect_to new_registration_path, inertia: { errors: user.errors.transform_values(&:first) }
    end
  end

  private

  def registration_params
    params.permit(:email_address, :password, :password_confirmation)
  end

  def redirect_if_authenticated
    redirect_to root_path if authenticated?
  end
end
