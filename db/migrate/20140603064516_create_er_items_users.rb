class CreateErItemsUsers < ActiveRecord::Migration
  def change
    create_table :er_items_users do |t|
      t.references :user, index: true, null: false
      t.references :item, index: true, null: false
      t.string     :wordbook_url, null: false
      t.foreign_key :er_users, column: :user_id
      t.foreign_key :er_items, column: :item_id

      t.timestamps
    end
  end
end
