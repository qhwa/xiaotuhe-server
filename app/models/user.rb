class User < ActiveRecord::Base

  class << self

    def find_or_create_from_auth_hash(auth)
      locate_email(auth) || create_user(auth)
    end

    def locate_email(auth)
      email = extract_email(auth)
      return nil unless email.present?
      User.find_by( email: email ).tap do |user|
        user.try :update, name: auth[:info][:nickname]
      end
    end

    def create_user(auth)
      # DEBUG
      # require 'pp'
      # pp auth
      info = auth[:info]
      create!(
        :name  => info[:nickname],
        :email => extract_email(auth)
      )
    end

    private

      def extract_email(auth)
        email = auth[:info][:email]
        return email if email.present?

        [auth[:uid], auth[:provider]].join('@@')
      end

  end

  validates_presence_of :name, :email
  validates_uniqueness_of :email

  has_many :shares, -> { order 'updated_at DESC' }, dependent: :destroy

  def can_renew? share
    share.user_id == id
  end

end
