class User < ActiveRecord::Base

  class << self

    def find_or_create_from_auth_hash(auth)
      locate_email(auth) || create_user(auth)
    end

    def locate_email(auth)
      User.find_by( email: auth[:info][:email] )
    end

    def create_user(auth)
      create!(
        :name  => auth[:info][:nickname],
        :email => auth[:info][:email]
      )
    end

  end

  validates_presence_of :name, :email
  validates_uniqueness_of :email

end
