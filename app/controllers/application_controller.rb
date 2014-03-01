class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  protected

    def render_failure_json msg: nil
      render json: {
        success: false,
        msg: msg
      }
    end
end
