require 'mime-types'

module SharesHelper

  def unzipped_path( share )
    if share.unzipped?
      "/" << share.extract_path
    end
  end

  def entry_tag( entry, base=nil )

    path = base.present? ? File.join(base, entry) : entry

    link_to entry, show_content_share_path( path: path ),
      'data-type' => MIME::Types.type_for( entry ),
      'class'     => 'entry'
  end

end
