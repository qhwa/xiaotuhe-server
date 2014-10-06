class AddSharesCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :shares_count, :integer, default: 0
  end
end
