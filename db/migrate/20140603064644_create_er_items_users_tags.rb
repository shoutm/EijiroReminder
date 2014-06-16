class CreateErItemsUsersTags < ActiveRecord::Migration
  def change
    create_table :er_items_users_tags do |t|
      t.references :items_user, index: true
      t.references :tag, index: true

      t.timestamps
    end
  end
end
