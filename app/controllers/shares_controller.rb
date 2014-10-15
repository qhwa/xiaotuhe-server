class SharesController < ApplicationController

  before_action :find_share, only: [:show, :append, :show_content, :destroy, :renew]
  before_action :require_user, only: [:mine]

  # GET /mine.html
  def mine
    @shares = current_user.shares.page(params[:page])
  end

  def create
    @share = Share.new app_params
    if current_user.present?
      @share.user = current_user
      @share.expires_at = 1.week.since
    else
      @share.expires_at = 1.day.since
    end

    if @share.save
      @attached = current_user.present?
      session[:ghost_share_id] = @share.id unless @attached
      @share.unzip
    else
      render_failure_json msg: @share.errors
    end
  end

  def show
    render 'expired' if @share.expired?
  end

  def append
    file = params[:file]
    path = params[:path]
    if file.present? && path.present?
      @share.append_file! file, path
    end
  end

  def show_content
    @path = params[:path] || ''
    if @share.unzipped?
      @entries = @share / @path
    end
  end

  def destroy
    @share.destroy
  end


  # PUT /shares/:key/renew
  def renew
    @share.update expires_at: 1.day.since
  end

  private

    def app_params
      params.permit(:file, :name)
    end

    def find_share
      @share = Share.find_by(key: params[:id]) or fail ActiveRecord::RecordNotFound
    end

    def can_attach_share? share
      session[:ghost_share_id] == share.id
    end

    helper_method :can_attach_share?

end
