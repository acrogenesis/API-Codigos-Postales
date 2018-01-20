class ChangeCodigoPostalToString < ActiveRecord::Migration[4.2]
  def change
    change_column :codigos_postales, :codigo_postal, :string
  end
end
