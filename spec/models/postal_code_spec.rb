require 'spec_helper'

RSpec.describe PostalCode do
  describe '.with_code' do
    let!(:postal_code) { create(:postal_code, codigo_postal: '12345') }
    let!(:other_postal_code) { create(:postal_code, codigo_postal: '54321') }

    it 'returns postal codes matching the given code' do
      expect(described_class.with_code('12345')).to include(postal_code)
      expect(described_class.with_code('12345')).not_to include(other_postal_code)
    end
  end

  describe '.with_code_hint' do
    let!(:postal_code1) { create(:postal_code, codigo_postal: '12345') }
    let!(:postal_code2) { create(:postal_code, codigo_postal: '12346') }
    let!(:other_postal_code) { create(:postal_code, codigo_postal: '54321') }

    it 'returns postal codes starting with the given prefix' do
      results = described_class.with_code_hint('123')
      expect(results).to include('12345', '12346')
      expect(results).not_to include('54321')
    end

    it 'returns results in ascending order' do
      results = described_class.with_code_hint('123')
      expect(results).to eq(results.sort)
    end
  end

  describe '.get_suburbs_for' do
    let!(:postal_code1) { create(:postal_code, codigo_postal: '12345', colonia: 'Colonia A') }
    let!(:postal_code2) { create(:postal_code, codigo_postal: '12345', colonia: 'Colonia B') }

    it 'returns all suburbs for a given postal code' do
      suburbs = described_class.get_suburbs_for('12345')
      expect(suburbs).to include('Colonia A', 'Colonia B')
    end
  end

  describe '.get_shared_data_for' do
    let!(:postal_code) do
      create(:postal_code,
             codigo_postal: '12345',
             municipio: 'Municipio Test',
             estado: 'Estado Test')
    end

    it 'returns municipio and estado for a given postal code' do
      data = described_class.get_shared_data_for('12345')
      expect(data).to eq([['Municipio Test', 'Estado Test']])
    end
  end
end