Cuba.define do
  on get do
    on root do
      res.write '<p>Danos un código postal y te regresamos la colonia, municipio y estado.
                 <p>Más información en <a href="https://rapidapi.com/acrogenesis/api/mexico-zip-codes">https://rapidapi.com/acrogenesis/api/mexico-zip-codes</a></p>'
    end

    on 'codigo_postal/:codigo_postal' do |codigo_postal|
      env['warden'].authenticate!(:token)
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'
      res.headers['Access-Control-Allow-Origin'] = 'http://localhost:3001'
      res.headers['Access-Control-Allow-Origin'] = '*'
      res.header['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
      res.header['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, Accept, X-User-Email, X-Auth-Token'
      res.header['Access-Control-Expose-Headers'] = 'X-Total, X-Total-Pages, X-Per-Page, X-Page, X-Next-Page, X-Prev-Page, X-Link'

      res.write Oj.dump(PostalCode.where(codigo_postal:)
        .as_json(except: :id), mode: :object)
    end

    on 'buscar', param('q') do |query|
      env['warden'].authenticate!(:token)
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.headers['Access-Control-Allow-Origin'] = '*'
      res.write Oj.dump(PostalCode.select('DISTINCT codigo_postal')
        .where('codigo_postal LIKE :prefix', prefix: "#{query}%")
        .order('codigo_postal ASC')
        .as_json(except: :id), mode: :object)
    end

    on 'v2/codigo_postal/:codigo_postal' do |codigo_postal|
      env['warden'].authenticate!(:token)
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.headers['Access-Control-Allow-Origin'] = '*'
      res.write PostalCodes.fetch_locations(codigo_postal)
    end

    on 'v2/buscar', param('codigo_postal') do |codigo_postal|
      env['warden'].authenticate!(:token)
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.headers['Access-Control-Allow-Origin'] = '*'
      res.write PostalCodes.fetch_codes(codigo_postal)
    end
  end
end
