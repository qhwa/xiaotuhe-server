class SharesController < ApplicationController

  before_action :find_share, only: [:show, :append, :show_content]
  before_action :require_user, only: [:mine]

  # GET /mine.html
  def mine
    @shares = current_user.shares.page(params[:page])
  end

  def create
    @share = Share.new app_params
    @share.user = current_user if current_user.present?
    if @share.save
      @share.unzip
    else
      render_failure_json msg: @share.errors
    end
  end

  def show
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

  private

    def app_params
      params.permit(:file, :name)
    end

    def find_share
      @share = Share.find_by key: params[:id]
    end

end
