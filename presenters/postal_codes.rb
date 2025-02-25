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
    normalized_estado = normalize_text(estado)
    normalized_municipio = normalize_text(municipio)
    normalized_colonia = normalize_text(colonia) if colonia.present?

    # For PostgreSQL, we could use the unaccent extension, but for wider compatibility
    # we'll use a more general approach
    estados = PostalCode.pluck(:estado).uniq
    matching_estados = estados.select { |e| normalize_text(e).downcase == normalized_estado.downcase }

    municipios = PostalCode.where(estado: matching_estados).pluck(:municipio).uniq
    matching_municipios = municipios.select { |m| normalize_text(m).downcase == normalized_municipio.downcase }

    query = PostalCode.where(estado: matching_estados, municipio: matching_municipios)

    matching_colonias = nil
    if colonia.present?
      colonias = query.pluck(:colonia).uniq
      matching_colonias = colonias.select { |c| normalize_text(c).downcase == normalized_colonia.downcase }
      query = query.where(colonia: matching_colonias)
    end

    {
      found_estado: matching_estados.first,
      found_municipio: matching_municipios.first,
      found_colonia: matching_colonias&.first,
      postal_codes: query.select('DISTINCT codigo_postal').order('codigo_postal ASC')
    }
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
