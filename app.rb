Cuba.define do
  on get do
    on root do
      res.write 'Danos un código postal y te regresamos la colonia, municipio y estado.
                 https://api-codigos-postales.herokuapp.com/codigo_postal/64600'
    end

    on 'codigo_postal/:codigo_postal' do |codigo_postal|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.headers['Access-Control-Allow-Origin'] = '*'
      res.write Oj.dump(PostalCode.where(codigo_postal: codigo_postal)
        .as_json(except: :id), mode: :object)
    end

    on 'buscar', param('q') do |query|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.headers['Access-Control-Allow-Origin'] = '*'
      res.write Oj.dump(PostalCode.select('DISTINCT codigo_postal')
        .where('codigo_postal LIKE :prefix', prefix: "#{query}%")
        .order('codigo_postal ASC')
        .as_json(except: :id), mode: :object)
    end
  end
end
