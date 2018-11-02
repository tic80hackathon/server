class AddDescriptionNameToCartridges < ActiveRecord::Migration[5.2]
  def change
      add_column :cartridges, :description, :string
      add_column :cartridges, :name, :string
  end
end
