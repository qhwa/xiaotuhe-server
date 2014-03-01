class AddOriginalNameToShares < ActiveRecord::Migration
  def change
    add_column :shares, :original_name, :string
  end
end
