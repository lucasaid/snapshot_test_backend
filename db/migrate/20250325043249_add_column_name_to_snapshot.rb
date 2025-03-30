class AddColumnNameToSnapshot < ActiveRecord::Migration[8.0]
  def change
    add_column :snapshots, :user_id, :integer
    add_column :snapshots, :top_image, :string
    add_column :snapshots, :front_image, :string
  end
end
