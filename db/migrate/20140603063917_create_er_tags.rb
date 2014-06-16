class CreateErTags < ActiveRecord::Migration
  def change
    create_table :er_tags do |t|
      t.string :name, null: false
      t.string :tag, null: false
      t.integer :interval, null: false

      t.timestamps
    end
  end
end
