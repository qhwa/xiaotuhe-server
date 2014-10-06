class SessionsController < ApplicationController
  
  # GET /signin
  def new
    save_back_url params[:back_to]
  end

  def create
    @user = User.find_or_create_from_auth_hash auth_hash
    self.current_user = @user
    if session[:ghost_share_id]
      Share.find_by( id: session.delete(:ghost_share_id) ).tap do |share|
        if share
          share.update user: @user
        end
      end
    end

    redirect_to( back_url || root_url ) and session.delete(:back_to)
  end

  # GET /signout
  # DELETE /sessions
  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  protected

    def save_back_url url
      if secure? url
        session[:back_to] = url
      end
    end

    def secure? url
      return false if url.blank?
      URI.parse(url).host == request.host
    end

    def auth_hash
      request.env['omniauth.auth']
    end

    def back_url
      if url = session[:back_to]
        return url if secure?(url)
      end
    end

end
