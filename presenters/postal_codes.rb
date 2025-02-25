module PostalCodes
  def self.fetch_codes(code)
    postal_codes = search_postal_codes(code)
    serialize("codigos_postales" => postal_codes)
  end

  def self.search_postal_codes(code)
    PostalCode.with_code_hint(code)
  end

  def self.fetch_locations(code)
    locations = search_locations(code)
    shared_data = shared_data(code)
    locations_json = prepare_locations_json(locations, code, shared_data)
    serialize(locations_json)
  end

  def self.search_locations(code)
    PostalCode.get_suburbs_for(code)
  end

  def self.shared_data(code)
    shared_data = PostalCode.get_shared_data_for(code)
    shared_data.flatten!
    shared_data = ['', ''] if shared_data.empty?
    shared_data
  end

  def self.prepare_locations_json(locations, code, shared_data)
    { 'codigo_postal' => code,
      'municipio' => shared_data[0],
      'estado' => shared_data[1],
      'colonias' => locations }
  end

  def self.prepare_postal_codes_json(codes)
    { 'codigos_postales' => codes }
  end

  def self.serialize(data)
    Oj.dump(data, mode: :object)
  end
end
