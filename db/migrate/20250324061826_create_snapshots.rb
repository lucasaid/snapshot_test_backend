class CreateSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :snapshots do |t|
      t.string :name

      t.timestamps
    end
  end
end
