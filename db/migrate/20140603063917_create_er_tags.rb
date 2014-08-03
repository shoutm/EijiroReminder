class CreateErTags < ActiveRecord::Migration
  def change
    create_table :er_tags do |t|
      t.string :name, null: false
      t.string :tag, null: false
      t.integer :interval, null: false
      t.integer :order, null: false

      t.timestamps
    end

    add_index :er_tags, :order, unique: true
  end
end
