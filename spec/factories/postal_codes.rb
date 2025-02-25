FactoryBot.define do
  factory :postal_code do
    codigo_postal { Faker::Number.number(digits: 5).to_s }
    colonia { Faker::Address.community }
    municipio { Faker::Address.city }
    estado { Faker::Address.state }
  end
end