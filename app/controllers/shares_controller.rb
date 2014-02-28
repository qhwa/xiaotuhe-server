class SharesController < ApplicationController

  def create
    @share = Share.new app_params
    @share.save
  end

  def show
    @share = Share.find_by key: params[:id]
  end

  private

    def app_params
      params.permit(:file)     
    end

end
