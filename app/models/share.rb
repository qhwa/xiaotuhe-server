class Share < ActiveRecord::Base

  mount_uploader :file, FileUploader

  validates_presence_of :file, :key
  before_validation :gen_key

  def to_param
    key
  end

  private

    def gen_key
      self.key ||= SecureRandom.hex(10)
    end

end
