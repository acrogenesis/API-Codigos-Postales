Cuba.define do
  on get do
    on root do
      res.write '<p>Danos un código postal y te regresamos la colonia, municipio y estado.
                 <p>Más información en <a href="https://rapidapi.com/acrogenesis/api/mexico-zip-codes">https://rapidapi.com/acrogenesis/api/mexico-zip-codes</a></p>'
    end

    on 'codigo_postal/:codigo_postal' do |codigo_postal|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.headers['Access-Control-Allow-Origin'] = '*'
      if (validate_header(req))
        res.write Oj.dump(PostalCode.where(codigo_postal: codigo_postal)
          .as_json(except: :id), mode: :object)
      else
        res.status = 401
        res.write Oj.dump({"Error" => "Not Authorized to use API. Check https://rapidapi.com/acrogenesis/api/mexico-zip-codes"})
      end
    end

    on 'buscar', param('q') do |query|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.headers['Access-Control-Allow-Origin'] = '*'
      if (validate_header(req))
        res.write Oj.dump(PostalCode.select('DISTINCT codigo_postal')
          .where('codigo_postal LIKE :prefix', prefix: "#{query}%")
          .order('codigo_postal ASC')
          .as_json(except: :id), mode: :object)
      else
        res.status = 401
        res.write Oj.dump({"Error" => "Not Authorized to use API. Check https://rapidapi.com/acrogenesis/api/mexico-zip-codes"})
      end
    end

    on 'v2/codigo_postal/:codigo_postal' do |codigo_postal|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.headers['Access-Control-Allow-Origin'] = '*'
      if (validate_header(req))
        res.write PostalCodes.fetch_locations(codigo_postal)
      else
        res.status = 401
        res.write Oj.dump({"Error" => "Not Authorized to use API. Check https://rapidapi.com/acrogenesis/api/mexico-zip-codes"})
      end
    end

    on 'v2/buscar', param('codigo_postal') do |codigo_postal|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.headers['Access-Control-Allow-Origin'] = '*'
      if (validate_header(req))
        res.write PostalCodes.fetch_codes(codigo_postal)
      else
        res.status = 401
        res.write Oj.dump({"Error" => "Not Authorized to use API. Check https://rapidapi.com/acrogenesis/api/mexico-zip-codes"})
      end
    end
  end
end

def validate_header(req)
  return true if ENV['VALIDATE_HEADER'].nil?
  return req.env["HTTP_#{ENV['VALIDATE_HEADER']}"] == ENV['VALIDATE_HEADER_VALUE']
end
