require 'spec_helper'

RSpec.describe 'API' do
  let(:valid_token) { 'test_token' }

  before do
    header 'X-RapidAPI-Key', valid_token
  end

  describe 'GET /' do
    it 'returns welcome message' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Danos un código postal')
    end
  end

  describe 'GET /codigo_postal/:codigo_postal' do
    let(:test_postal_code) { '12345' }
    let(:test_municipio) { 'Test Municipio' }
    let(:test_estado) { 'Test Estado' }
    let(:test_colonias) { ['Colonia A', 'Colonia B', 'Colonia C', 'Colonia D', 'Colonia E'] }

    context 'with valid postal code' do
      before do
        test_colonias.each do |colonia|
          create(:postal_code,
                 codigo_postal: test_postal_code,
                 colonia: colonia,
                 municipio: test_municipio,
                 estado: test_estado)
        end
      end

      it 'returns correct postal code information' do
        get "/codigo_postal/#{test_postal_code}"
        expect(last_response).to be_ok
        expect(last_response.headers['Content-Type']).to include('application/json')

        json_response = Oj.load(last_response.body)
        expect(json_response.first).to include(
          'codigo_postal' => test_postal_code,
          'municipio' => test_municipio,
          'estado' => test_estado
        )

        colonias = json_response.map { |pc| pc['colonia'] }
        expect(colonias).to match_array(test_colonias)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        header 'X-RapidAPI-Key', nil
        get "/codigo_postal/#{test_postal_code}"
        expect(last_response.status).to eq(401)
      end
    end
  end

  describe 'GET /buscar' do
    let!(:postal_code1) { create(:postal_code, codigo_postal: '12345') }
    let!(:postal_code2) { create(:postal_code, codigo_postal: '12346') }

    it 'returns matching postal codes' do
      get '/buscar?q=123'
      expect(last_response).to be_ok
      expect(last_response.headers['Content-Type']).to include('application/json')

      json_response = Oj.load(last_response.body)
      puts "Response body: #{last_response.body}"
      expect(json_response).to match_array([{ 'codigo_postal' => '12345' }, { 'codigo_postal' => '12346' }])
    end
  end

  describe 'GET /v2/codigo_postal/:codigo_postal' do
    let(:test_postal_code) { '12345' }
    let(:test_municipio) { 'Test Municipio' }
    let(:test_estado) { 'Test Estado' }
    let(:test_colonias) { ['Colonia A', 'Colonia B'] }

    before do
      test_colonias.each do |colonia|
        create(:postal_code,
               codigo_postal: test_postal_code,
               colonia: colonia,
               municipio: test_municipio,
               estado: test_estado)
      end
    end

    it 'returns postal code information in v2 format' do
      get "/v2/codigo_postal/#{test_postal_code}"
      expect(last_response).to be_ok
      expect(last_response.headers['Content-Type']).to include('application/json')

      json_response = Oj.load(last_response.body)
      expect(json_response).to include(
        'codigo_postal' => test_postal_code,
        'municipio' => test_municipio,
        'estado' => test_estado
      )
      expect(json_response['colonias']).to match_array(test_colonias)
    end
  end

  describe 'GET /v2/buscar' do
    let!(:postal_code1) { create(:postal_code, codigo_postal: '12345') }
    let!(:postal_code2) { create(:postal_code, codigo_postal: '12346') }

    it 'returns matching postal codes in v2 format' do
      get '/v2/buscar?codigo_postal=123'
      expect(last_response).to be_ok
      expect(last_response.headers['Content-Type']).to include('application/json')

      json_response = Oj.load(last_response.body)
      puts "Response body: #{last_response.body}"
      expect(json_response['codigos_postales']).to match_array(%w[12345 12346])
    end
  end

  describe 'GET /v2/buscar_por_ubicacion' do
    let(:test_estado) { 'Test Estado' }
    let(:test_municipio) { 'Test Municipio' }
    let(:test_colonia) { 'Test Colonia' }

    before do
      # Create some postal codes with the same estado and municipio but different colonias
      create(:postal_code,
             codigo_postal: '12345',
             estado: test_estado,
             municipio: test_municipio,
             colonia: test_colonia)

      create(:postal_code,
             codigo_postal: '12346',
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

    context 'with estado and municipio parameters' do
      it 'returns all matching postal codes' do
        get "/v2/buscar_por_ubicacion?estado=#{test_estado}&municipio=#{test_municipio}"
        expect(last_response).to be_ok
        expect(last_response.headers['Content-Type']).to include('application/json')

        json_response = Oj.load(last_response.body)
        expect(json_response).to have_key('codigos_postales')
        expect(json_response['codigos_postales']).to match_array(%w[12345 12346])
      end
    end

    context 'with estado, municipio and colonia parameters' do
      it 'returns matching postal codes filtered by colonia' do
        get "/v2/buscar_por_ubicacion?estado=#{test_estado}&municipio=#{test_municipio}&colonia=#{test_colonia}"
        expect(last_response).to be_ok

        json_response = Oj.load(last_response.body)
        expect(json_response).to have_key('codigos_postales')
        expect(json_response['codigos_postales']).to match_array(['12345'])
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        header 'X-RapidAPI-Key', nil
        get "/v2/buscar_por_ubicacion?estado=#{test_estado}&municipio=#{test_municipio}"
        expect(last_response.status).to eq(401)
      end
    end
  end
end
