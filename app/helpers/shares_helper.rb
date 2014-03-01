module SharesHelper

  def unzipped_path( share )
    if share.unzipped?
      "/" << share.extract_path
    end
  end

end
