module PostalCodes
  def self.fetch_codes(code)
    postal_codes = search_postal_codes(code)
    serialize('codigos_postales' => postal_codes)
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

  def self.fetch_by_location(estado, municipio, colonia = nil)
    postal_codes = search_by_location(estado, municipio, colonia)
    locations_json = prepare_location_search_json(postal_codes, estado, municipio, colonia)
    serialize(locations_json)
  end

  def self.search_by_location(estado, municipio, colonia = nil)
    # Use PostgreSQL's unaccent extension for better performance
    query = PostalCode

    # Find matching estado
    matching_estado = query.where("unaccent(lower(estado)) = unaccent(lower(?))", estado).pluck(:estado).first

    if matching_estado
      query = query.where(estado: matching_estado)

      # Find matching municipio
      matching_municipio = query.where("unaccent(lower(municipio)) = unaccent(lower(?))", municipio).pluck(:municipio).first

      if matching_municipio
        query = query.where(municipio: matching_municipio)

        # Find matching colonia if provided
        matching_colonia = nil
        if colonia.present?
          matching_colonia = query.where("unaccent(lower(colonia)) = unaccent(lower(?))", colonia).pluck(:colonia).first
          query = query.where(colonia: matching_colonia) if matching_colonia
        end

        {
          found_estado: matching_estado,
          found_municipio: matching_municipio,
          found_colonia: matching_colonia,
          postal_codes: query.select('DISTINCT codigo_postal').order('codigo_postal ASC')
        }
      else
        { found_estado: matching_estado, found_municipio: nil, found_colonia: nil, postal_codes: [] }
      end
    else
      { found_estado: nil, found_municipio: nil, found_colonia: nil, postal_codes: [] }
    end
  end

  def self.normalize_text(text)
    return nil if text.nil?

    # Remove accents and special characters (á -> a, é -> e, etc.)
    text.unicode_normalize(:nfkd).gsub(/[^\x00-\x7F]/n, '')
  end

  def self.prepare_location_search_json(search_result, _estado, _municipio, _colonia)
    { 'codigos_postales' => search_result[:postal_codes].map(&:codigo_postal) }
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

  private_class_method :search_postal_codes, :search_locations, :search_by_location,
                       :shared_data, :prepare_locations_json, :prepare_location_search_json,
                       :prepare_postal_codes_json, :serialize
end
