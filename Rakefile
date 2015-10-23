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

    uri = URI.parse('http://www.correosdemexico.gob.mx/lservicios/servicios/CodigoPostal_Exportar.aspx')

    params = {
      '__VIEWSTATE' => '/wEPDwUKMTIxMDU0NDIwMA9kFgICAQ9kFgICAQ9kFgYCAw8PFgIeBFRleHQFOsOabHRpbWEgQWN0dWFsaXphY2nDs24gZGUgSW5mb3JtYWNpw7NuOiBPY3R1YnJlIDEyIGRlIDIwMTVkZAIHDxAPFgYeDURhdGFUZXh0RmllbGQFA0Vkbx4ORGF0YVZhbHVlRmllbGQFBUlkRWRvHgtfIURhdGFCb3VuZGdkEBUhIy0tLS0tLS0tLS0gVCAgbyAgZCAgbyAgcyAtLS0tLS0tLS0tDkFndWFzY2FsaWVudGVzD0JhamEgQ2FsaWZvcm5pYRNCYWphIENhbGlmb3JuaWEgU3VyCENhbXBlY2hlFENvYWh1aWxhIGRlIFphcmFnb3phBkNvbGltYQdDaGlhcGFzCUNoaWh1YWh1YRBEaXN0cml0byBGZWRlcmFsB0R1cmFuZ28KR3VhbmFqdWF0bwhHdWVycmVybwdIaWRhbGdvB0phbGlzY28HTcOpeGljbxRNaWNob2Fjw6FuIGRlIE9jYW1wbwdNb3JlbG9zB05heWFyaXQLTnVldm8gTGXDs24GT2F4YWNhBlB1ZWJsYQpRdWVyw6l0YXJvDFF1aW50YW5hIFJvbxBTYW4gTHVpcyBQb3Rvc8OtB1NpbmFsb2EGU29ub3JhB1RhYmFzY28KVGFtYXVsaXBhcwhUbGF4Y2FsYR9WZXJhY3J1eiBkZSBJZ25hY2lvIGRlIGxhIExsYXZlCFl1Y2F0w6FuCVphY2F0ZWNhcxUhAjAwAjAxAjAyAjAzAjA0AjA1AjA2AjA3AjA4AjA5AjEwAjExAjEyAjEzAjE0AjE1AjE2AjE3AjE4AjE5AjIwAjIxAjIyAjIzAjI0AjI1AjI2AjI3AjI4AjI5AjMwAjMxAjMyFCsDIWdnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2RkAh0PPCsACwBkGAEFHl9fQ29udHJvbHNSZXF1aXJlUG9zdEJhY2tLZXlfXxYBBQtidG5EZXNjYXJnYW7mKf2QWdV7ACF9fcRwj17tjpW4',
      '__EVENTVALIDATION' => '/wEWKAKgn7qiAQLG/OLvBgLWk4iCCgLWk4SCCgLWk4CCCgLWk7yCCgLWk7iCCgLWk7SCCgLWk7CCCgLWk6yCCgLWk+iBCgLWk+SBCgLJk4iCCgLJk4SCCgLJk4CCCgLJk7yCCgLJk7iCCgLJk7SCCgLJk7CCCgLJk6yCCgLJk+iBCgLJk+SBCgLIk4iCCgLIk4SCCgLIk4CCCgLIk7yCCgLIk7iCCgLIk7SCCgLIk7CCCgLIk6yCCgLIk+iBCgLIk+SBCgLLk4iCCgLLk4SCCgLLk4CCCgLL+uTWBALa4Za4AgK+qOyRAQLI56b6CwL1/KjtBePsl9sOAa2kuhQy2NGiYZah6Oiv',
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
