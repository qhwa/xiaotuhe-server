class SharesController < ApplicationController

  def create
    @share = Share.new app_params
    if @share.save
      @share.unzip if params[:options] && params[:options]['unzip'] == "true"
    else
      render_failure_json msg: @share.errors
    end
  end

  def show
    @share = Share.find_by key: params[:id]
  end

  private

    def app_params
      params.permit(:file, :name)
    end

end
