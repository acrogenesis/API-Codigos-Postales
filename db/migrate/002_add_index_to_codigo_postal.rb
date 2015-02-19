class AddIndexToCodigoPostal < ActiveRecord::Migration
  def change
    add_index :codigos_postales, :codigo_postal
  end
end
