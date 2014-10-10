class WelcomeController < ApplicationController

  def index
    redirect_to signin_path unless current_user.present?
  end

end
