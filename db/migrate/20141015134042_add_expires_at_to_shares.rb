class AddExpiresAtToShares < ActiveRecord::Migration
  def self.up
    add_column :shares, :expires_at, :datetime

    Share.find_each do |share|
      share.update expires_at: share.created_at.in( 1.day )
    end
  end

  def self.down
    remove_column :shares, :expires_at
  end
end
