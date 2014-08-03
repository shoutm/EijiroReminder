class CreateErItemsUsersTags < ActiveRecord::Migration
  def change
    create_table :er_items_users_tags do |t|
      t.references :items_user, index: true, null: false
      t.references :tag,        index: true, null: false
      t.datetime   :registration_date, null: false
      t.foreign_key :er_items_users, column: :items_user_id
      t.foreign_key :er_tags, column: :tag_id

      t.timestamps
    end
  end
end
