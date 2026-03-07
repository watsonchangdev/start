# frozen_string_literal: true

class WelcomeController < InertiaController
  def home
    render inertia: "Home"
  end
end
