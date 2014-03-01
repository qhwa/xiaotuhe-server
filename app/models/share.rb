require 'fileutils'
require 'zip'
require 'string/utf8'

class Share < ActiveRecord::Base

  mount_uploader :file, FileUploader

  alias_attribute :name, :original_name

  validates_presence_of   :file, :key
  validates_uniqueness_of :key
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
            FileUtils.mkdir_p File.dirname(f)
            file.extract f
          end
        end
      rescue => e
        logger.fatal "Error on extracting id asset #{self.id}"
        logger.fatal e.inspect
        raise
      end
    end
  end

  def can_unzip?
    !unzipped? and file.file.file =~ /\.zip$/
  end

  def unzipped?
    persisted? and File.directory?( extract_target_dir )
  end

  def extract_path
    File.join "shares", key, "unzip/"
  end

  def image?
    file.file.file =~ /\.(png|jpe?g|gif|webp)$/
  end

  private

    def gen_key
      self.key ||= SecureRandom.hex(10)
    end

    def extract_target_dir
      File.join Rails.application.root, "public", extract_path
    end

end
