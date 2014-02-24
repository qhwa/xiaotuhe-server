class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.string :file
      t.string :file_file_name
      t.integer :file_file_size
      t.string :key

      t.timestamps
    end
    add_index :shares, :file_file_name
    add_index :shares, :key
  end
end
