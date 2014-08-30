require 'mime-types'

module SharesHelper

  def unzipped_path( share )
    if share.unzipped?
      "/" << share.extract_path
    end
  end

  def entry_tag( entry, base: nil, html_opts: {} )

    path = base.present? ? File.join(base, entry) : entry

    link_to entry, show_content_share_path( path: path ), {
      'data-type' => MIME::Types.type_for( entry ).first.try(:simplified),
      'class'     => 'entry'
    }.merge(html_opts)
  end

  def entry_size( path )
    number_to_human_size @share.entry_size( path )
  end

end
