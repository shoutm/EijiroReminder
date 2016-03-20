class AddDisabledFlagToErItems < ActiveRecord::Migration
  def change
    add_column :er_items, :disabled, :boolean, :default => false
  end
end
