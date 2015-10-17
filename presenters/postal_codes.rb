module PostalCodes

  def self.fetch_codes(code)
    postal_codes = search_postal_codes(code)
    serialize(postal_codes)
  end

  def self.search_postal_codes(code)
    postal_codes = PostalCode.select('DISTINCT codigo_postal')
      .where('codigo_postal LIKE :prefix', prefix: "#{code}%")
      .order('codigo_postal ASC')
  end

  def self.fetch_locations(code)
    locations = search_locations(code)
    serialize(locations)
  end

  def self.search_locations(code)
    locations = PostalCode.where(codigo_postal: code)
  end

  def self.serialize(data)
    json = { 'codigos_postales' => data.as_json(except: :id) }
    Oj.dump(json, mode: :object)
  end

end
