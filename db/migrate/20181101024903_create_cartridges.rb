class CreateCartridges < ActiveRecord::Migration[5.2]
  def change
    create_table :cartridges do |t| 
      t.binary :tic
      t.timestamps
    end
  end
end
