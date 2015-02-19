class ChangeCodigoPostalToString < ActiveRecord::Migration
  def change
    change_column :codigos_postales, :codigo_postal, :string
  end
end
