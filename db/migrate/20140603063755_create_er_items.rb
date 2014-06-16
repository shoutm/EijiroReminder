class CreateErItems < ActiveRecord::Migration
  def change
    create_table :er_items do |t|
      t.integer :e_id
      t.string :name

      t.timestamps
    end
  end
end
