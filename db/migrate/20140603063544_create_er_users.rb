class CreateErUsers < ActiveRecord::Migration
  def change
    create_table :er_users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password, null: false

      t.timestamps
    end
  end
end
