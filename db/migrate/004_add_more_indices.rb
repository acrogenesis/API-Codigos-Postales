class AddMoreIndices < ActiveRecord::Migration[4.2]
  def change
    # Add indices for fields frequently used in queries
    add_index :codigos_postales, :estado
    add_index :codigos_postales, :municipio
    add_index :codigos_postales, :colonia

    # Add composite indices for common search patterns
    add_index :codigos_postales, [:estado, :municipio]
    add_index :codigos_postales, [:estado, :municipio, :colonia]
  end
end