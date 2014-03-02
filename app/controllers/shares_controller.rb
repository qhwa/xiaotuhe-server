class SharesController < ApplicationController

  before_filter :find_share, only: [:show, :append]

  def create
    @share = Share.new app_params
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

  private

    def app_params
      params.permit(:file, :name)
    end

    def find_share
      @share = Share.find_by key: params[:id]
    end

end
