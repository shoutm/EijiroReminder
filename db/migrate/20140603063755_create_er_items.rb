class CreateErItems < ActiveRecord::Migration
  def change
    create_table :er_items do |t|
      t.integer :e_id, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
