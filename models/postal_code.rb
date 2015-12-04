class PostalCode < ActiveRecord::Base
  self.table_name = 'codigos_postales'

  scope :with_code, -> (code) { where(codigo_postal: code) }

  def self.with_code_hint(code_hint)
    where('codigo_postal LIKE :prefix', prefix: "#{code_hint}%")
      .order(codigo_postal: :asc)
      .distinct
      .pluck(:codigo_postal)
  end

  def self.get_suburbs_for(code)
    with_code(code).pluck(:colonia)
  end

  def self.get_shared_data_for(code)
    with_code(code).limit(1).pluck(:municipio, :estado)
  end
end
