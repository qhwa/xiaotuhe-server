require 'fileutils'
require 'zip'
require 'string/utf8'

class Share < ActiveRecord::Base

  include FileUtils

  mount_uploader :file, FileUploader

  alias_attribute :name, :original_name

  validates :key, presence: true, uniqueness: true
  before_validation :gen_key

  def to_param
    key
  end

  def unzip
    if can_unzip?
      begin
        dir = extract_target_dir
        Zip::File.new( file.path ).each do |file|
          unless file.to_s =~ /__MACOSX/
            f = File.join( dir, file.name.utf8! )
            mkdir_p File.dirname(f)
            file.extract f
          end
        end
      rescue => e
        logger.fatal "Error on extracting id asset #{self.id}"
        logger.fatal e.inspect
      end
    end
  end

  def can_unzip?
    !unzipped? and file.try(:file) && file.file.file =~ /\.zip$/
  end

  def unzipped?
    persisted? and File.directory?( extract_target_dir )
  end

  def extract_path
    File.join "shares", key, "unzip/"
  end

  def image?
    file.try(:file) && file.file.file =~ /\.(png|jpe?g|gif|webp)$/
  end

  def append_file! file, path
    raise "invalid path" if path =~ %r{\.\./}
    full_path = File.join( extract_target_dir, path )
    mkdir_p File.dirname( full_path )
    cp file.path, full_path
    chmod 0644, full_path
  end

  private

    def gen_key
      self.key ||= SecureRandom.hex(10)
    end

    def extract_target_dir
      File.join Rails.application.root, "public", extract_path
    end

end
