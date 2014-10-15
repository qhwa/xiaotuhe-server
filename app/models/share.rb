require 'fileutils'
require 'zip'
require 'string/utf8'

class Share < ActiveRecord::Base

  include FileUtils

  mount_uploader :file, FileUploader

  belongs_to :user, counter_cache: true
  alias_attribute :name, :original_name

  validates :key, presence: true, uniqueness: true
  before_validation :gen_key

  scope :expired, -> { where(["expires_at <= ?", DateTime.now]) }
  scope :working, -> { where(["expires_at >  ?", DateTime.now]) }

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
    raise "invalid path" if secure_path?(path)
    full_path = File.join( extract_target_dir, path )
    mkdir_p File.dirname( full_path )
    cp file.path, full_path
    chmod 0644, full_path
  end

  def / path
    if unzipped?
      Dir.entries( full_path( path ) ).reject do |p|
        p =~ /^\.+$/
      end.map {|f| [f, File.directory?(f)]}.sort do |a, b|
        if a[1] == b[1]
          a[0] <=> b[0]
        else
          a[1] ? -1 : 1
        end
      end.map(&:first)
    end
  end

  def entry_size path
    File.size( full_path(path) )
  end

  def folder? path
    File.directory?( full_path(path) )
  end

  def expired?
    !working?
  end

  def working?
    expires_at && expires_at > DateTime.now
  end

  private

    def full_path( path )
      raise "invalid path" if secure_path?(path)
      File.join extract_target_dir, path 
    end

    def gen_key
      self.key ||= SecureRandom.hex(10)
    end

    def extract_target_dir
      File.join Rails.application.root, "public", extract_path
    end

    def secure_path? path
     !!(path =~ %r{\.\./})
    end
end
