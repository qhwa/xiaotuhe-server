class SharesController < ApplicationController

  def create
    @share = Share.new app_params
    @share.save
  end

  private

    def app_params
      params.permit(:file)     
    end

end
