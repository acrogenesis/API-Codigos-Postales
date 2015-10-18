module PostalCodes

  def self.fetch_codes(code)
    postal_codes = search_postal_codes(code)
    postal_codes_json = prepare_json(postal_codes)
    serialize(postal_codes_json)
  end

  def self.search_postal_codes(code)
    postal_codes = PostalCode.select('DISTINCT codigo_postal')
      .where('codigo_postal LIKE :prefix', prefix: "#{code}%")
      .order('codigo_postal ASC')
  end

  def self.fetch_locations(code)
    locations = search_locations(code)
    locations_json = prepare_json(locations)
    serialize(locations_json)
  end

  def self.search_locations(code)
    locations = PostalCode.where(codigo_postal: code)
  end

  def self.prepare_json(data)
    data.as_json(except: :id)
  end

  def self.serialize(data)
    Oj.dump(data, mode: :object)
  end

end
