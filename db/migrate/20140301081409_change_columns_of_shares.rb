class ChangeColumnsOfShares < ActiveRecord::Migration
  def change
    rename_column :shares, :file_file_size, :file_size
    rename_column :shares, :file_file_name, :content_type
  end
end
