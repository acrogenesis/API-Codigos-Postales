require 'active_record'
require 'yaml'
require './db'
desc 'Run migrations'
namespace :db do
  task :migrate do
    ActiveRecord::Migrator.migrate('db/migrate', ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end

  task :rollback do
    ActiveRecord::Migrator.rollback('db/migrate', ENV['STEPS'] ? ENV['STEPS'].to_i : 1)
  end
end

namespace :sepomex do
  task :update do
    require 'net/http'
    require 'uri'
    require 'zip'
    require 'csv'
    require './models/postal_code'

    uri = URI.parse('https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/CodigoPostal_Exportar.aspx')

    params = {
      '__VIEWSTATE' => '/wEPDwUINzcwOTQyOTgPZBYCAgEPZBYCAgEPZBYGAgMPDxYCHgRUZXh0BTrDmmx0aW1hIEFjdHVhbGl6YWNpw7NuIGRlIEluZm9ybWFjacOzbjogRmVicmVybyAyOCBkZSAyMDE5ZGQCBw8QDxYGHg1EYXRhVGV4dEZpZWxkBQNFZG8eDkRhdGFWYWx1ZUZpZWxkBQVJZEVkbx4LXyFEYXRhQm91bmRnZBAVISMtLS0tLS0tLS0tIFQgIG8gIGQgIG8gIHMgLS0tLS0tLS0tLQ5BZ3Vhc2NhbGllbnRlcw9CYWphIENhbGlmb3JuaWETQmFqYSBDYWxpZm9ybmlhIFN1cghDYW1wZWNoZRRDb2FodWlsYSBkZSBaYXJhZ296YQZDb2xpbWEHQ2hpYXBhcwlDaGlodWFodWERQ2l1ZGFkIGRlIE3DqXhpY28HRHVyYW5nbwpHdWFuYWp1YXRvCEd1ZXJyZXJvB0hpZGFsZ28HSmFsaXNjbwdNw6l4aWNvFE1pY2hvYWPDoW4gZGUgT2NhbXBvB01vcmVsb3MHTmF5YXJpdAtOdWV2byBMZcOzbgZPYXhhY2EGUHVlYmxhClF1ZXLDqXRhcm8MUXVpbnRhbmEgUm9vEFNhbiBMdWlzIFBvdG9zw60HU2luYWxvYQZTb25vcmEHVGFiYXNjbwpUYW1hdWxpcGFzCFRsYXhjYWxhH1ZlcmFjcnV6IGRlIElnbmFjaW8gZGUgbGEgTGxhdmUIWXVjYXTDoW4JWmFjYXRlY2FzFSECMDACMDECMDICMDMCMDQCMDUCMDYCMDcCMDgCMDkCMTACMTECMTICMTMCMTQCMTUCMTYCMTcCMTgCMTkCMjACMjECMjICMjMCMjQCMjUCMjYCMjcCMjgCMjkCMzACMzECMzIUKwMhZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZGQCHQ88KwALAGQYAQUeX19Db250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgEFC2J0bkRlc2NhcmdhqRZm1BP66KzYxUpp1Ej06LEoJ10=',
      '__VIEWSTATEGENERATOR' => 'BE1A6D2E',
      '__EVENTVALIDATION' => '/wEWKALhkeqeAQLG/OLvBgLWk4iCCgLWk4SCCgLWk4CCCgLWk7yCCgLWk7iCCgLWk7SCCgLWk7CCCgLWk6yCCgLWk+iBCgLWk+SBCgLJk4iCCgLJk4SCCgLJk4CCCgLJk7yCCgLJk7iCCgLJk7SCCgLJk7CCCgLJk6yCCgLJk+iBCgLJk+SBCgLIk4iCCgLIk4SCCgLIk4CCCgLIk7yCCgLIk7iCCgLIk7SCCgLIk7CCCgLIk6yCCgLIk+iBCgLIk+SBCgLLk4iCCgLLk4SCCgLLk4CCCgLL+uTWBALa4Za4AgK+qOyRAQLI56b6CwL1/KjtBQShtqSfolZPHREbgq/CaRh97SO2',
      'cboEdo' => '00',
      'rblTipo' => 'txt',
      'btnDescarga.x' => '44',
      'btnDescarga.y' => '10'
    }
    puts 'Downloading postal codes from SEPOMEX'
    response_post = Net::HTTP.post_form(uri, params)

    puts 'Writing Zip'
    File.open('latest.zip', 'w') do |file|
      file.write response_post.body
    end

    puts 'Extracting Zip'
    Zip::File.open('latest.zip') do |zip_file|
      zip_file.extract('CPdescarga.txt', 'latest.csv') { true }
    end

    puts 'Parsing Postal Codes'
    csv_text = File.readlines('latest.csv', encoding: 'ISO-8859-1:UTF-8')[1..-1].join
    csv = CSV.parse(csv_text, col_sep: '|', quote_char: '%', headers: :first_row, return_headers: true)
    csv.delete('d_tipo_asenta')
    csv.delete('c_estado')
    csv.delete('d_CP')
    csv.delete('c_oficina')
    csv.delete('c_CP')
    csv.delete('c_tipo_asenta')
    csv.delete('c_mnpio')
    csv.delete('c_mnpio')
    csv.delete('id_asenta_cpcons')
    csv.delete('d_zona')
    csv.delete('c_cve_ciudad')
    csv.delete('d_ciudad')

    puts 'Inserting new Postal Codes'
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    count = 0
    total = csv.count
    csv.each do |row|
      arg = {}
      row_h = row.to_h
      arg[:codigo_postal] = row_h['d_codigo']
      arg[:colonia] = row_h['d_asenta']
      arg[:municipio] = row_h['D_mnpio']
      arg[:estado] = row_h['d_estado']
      PostalCode.find_or_create_by(arg)
      print "#{(100 * count) / total}% \r"
      count += 1
    end
    ActiveRecord::Base.logger = old_logger
    puts ''
    puts 'Removing TempFiles'
    File.delete('latest.csv')
    File.delete('latest.zip')
  end
end
