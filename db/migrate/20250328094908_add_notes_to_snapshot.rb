class AddNotesToSnapshot < ActiveRecord::Migration[8.0]
  def change
    add_column :snapshots, :notes, :text
  end
end
