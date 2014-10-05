class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def current_user
    @current_user ||= User.find(session[:user_id])
  end

  def current_user=(user)
    if user.present?
      session[:user_id] = user
    else
      session[:user_id] = nil
    end
  end

  protected

    def render_failure_json msg: nil
      render json: {
        success: false,
        msg: msg
      }
    end
end
