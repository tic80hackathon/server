class AddUserIdAndDisplayNameToCartridges < ActiveRecord::Migration[5.2]
  def change
    add_column :cartridges, :user_id, :string
    add_column :cartridges, :display_name, :string
  end
end
