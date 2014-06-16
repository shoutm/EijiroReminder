class CreateErItemsUsers < ActiveRecord::Migration
  def change
    create_table :er_items_users do |t|
      t.references :user, index: true
      t.references :item, index: true

      t.timestamps
    end
  end
end
