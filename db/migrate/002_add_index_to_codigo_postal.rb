class AddIndexToCodigoPostal < ActiveRecord::Migration[4.2]
  def change
    add_index :codigos_postales, :codigo_postal
  end
end
