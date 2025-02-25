require 'spec_helper'

RSpec.describe PostalCodes do
  describe '.fetch_by_location' do
    let(:test_estado) { 'Test Estado' }
    let(:test_municipio) { 'Test Municipio' }
    let(:test_colonia) { 'Test Colonia' }
    let(:test_codigo_postal1) { '12345' }
    let(:test_codigo_postal2) { '12346' }

    before do
      # Create some postal codes with the same estado and municipio but different colonias
      create(:postal_code,
             codigo_postal: test_codigo_postal1,
             estado: test_estado,
             municipio: test_municipio,
             colonia: test_colonia)

      create(:postal_code,
             codigo_postal: test_codigo_postal2,
             estado: test_estado,
             municipio: test_municipio,
             colonia: 'Different Colonia')

      # Create a postal code with different estado
      create(:postal_code,
             codigo_postal: '54321',
             estado: 'Different Estado',
             municipio: test_municipio,
             colonia: test_colonia)
    end

    context 'when searching with estado and municipio' do
      it 'returns all matching postal codes' do
        result = PostalCodes.fetch_by_location(test_estado, test_municipio)
        json_response = Oj.load(result)

        expect(json_response).to have_key('codigos_postales')
        expect(json_response['codigos_postales']).to match_array([test_codigo_postal1, test_codigo_postal2])
      end
    end

    context 'when searching with estado, municipio and colonia' do
      it 'returns postal codes filtered by colonia' do
        result = PostalCodes.fetch_by_location(test_estado, test_municipio, test_colonia)
        json_response = Oj.load(result)

        expect(json_response).to have_key('codigos_postales')
        expect(json_response['codigos_postales']).to match_array([test_codigo_postal1])
      end
    end

    context 'when no matching postal codes are found' do
      it 'returns an empty array of postal codes' do
        result = PostalCodes.fetch_by_location('Non-existent Estado', 'Non-existent Municipio')
        json_response = Oj.load(result)

        expect(json_response).to have_key('codigos_postales')
        expect(json_response['codigos_postales']).to be_empty
      end
    end

    context 'when searching with different case' do
      it 'ignores case differences in estado and municipio' do
        # Using different case
        result = PostalCodes.fetch_by_location(test_estado.upcase, test_municipio.downcase)
        json_response = Oj.load(result)

        expect(json_response).to have_key('codigos_postales')
        expect(json_response['codigos_postales']).to match_array([test_codigo_postal1, test_codigo_postal2])
      end

      it 'ignores case differences in colonia' do
        # Using different case for colonia
        result = PostalCodes.fetch_by_location(test_estado, test_municipio, test_colonia.upcase)
        json_response = Oj.load(result)

        expect(json_response).to have_key('codigos_postales')
        expect(json_response['codigos_postales']).to match_array([test_codigo_postal1])
      end
    end

    context 'when searching with accented characters' do
      let(:accented_estado) { 'Nuevo León' }
      let(:accented_municipio) { 'San Nicolás' }
      let(:accented_colonia) { 'Jardín de las Américas' }
      let(:accented_codigo_postal) { '54321' }

      before do
        create(:postal_code,
               codigo_postal: accented_codigo_postal,
               estado: accented_estado,
               municipio: accented_municipio,
               colonia: accented_colonia)
      end

      it 'ignores accents in search parameters' do
        # Search without accents
        result = PostalCodes.fetch_by_location('Nuevo Leon', 'San Nicolas', 'Jardin de las Americas')
        json_response = Oj.load(result)

        expect(json_response).to have_key('codigos_postales')
        expect(json_response['codigos_postales']).to match_array([accented_codigo_postal])
      end

      it 'finds records with accents when searching without accents' do
        # Mix of accented and non-accented search parameters
        result = PostalCodes.fetch_by_location('Nuevo León', 'San Nicolas')
        json_response = Oj.load(result)

        expect(json_response).to have_key('codigos_postales')
        expect(json_response['codigos_postales']).to match_array([accented_codigo_postal])
      end
    end
  end
end
