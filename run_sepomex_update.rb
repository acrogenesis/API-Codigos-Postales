# run_sepomex_update.rb

# Requires - ensure csv is required early, before potential conflicts
require 'csv'
require 'active_record'
require 'yaml'
require 'net/http'
require 'uri'
require 'zip'
require './db'          # Establish DB connection
require './models/postal_code' # Load the model


# --- Start of copied logic from Rake task ---
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
  # Ensure the directory exists if needed, though extracting to current dir is likely fine
  zip_file.extract('CPdescarga.txt', 'latest.csv') { true } # Overwrite if exists
end

puts 'Parsing Postal Codes'
# Use File.read for simplicity if memory allows, otherwise stick with readlines
csv_text = File.read('latest.csv', encoding: 'ISO-8859-1:UTF-8').lines[1..].join # Skip header line
csv = CSV.parse(csv_text, col_sep: '|', quote_char: '%', headers: :first_row, return_headers: false) # Don't return headers here

# Removed unnecessary csv.delete calls as CSV.parse with headers: :first_row handles it.

puts 'Inserting new Postal Codes'
old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil # Temporarily disable verbose SQL logging
count = 0
total_rows = 0
csv.each { |_| total_rows += 1 } # Get total count first for percentage
# Use find_or_initialize_by + save for potential efficiency, or stick with find_or_create_by
csv.each do |row|
  arg = {}
  row_h = row.to_h
  arg[:codigo_postal] = row_h['d_codigo']
  arg[:colonia] = row_h['d_asenta']
  arg[:municipio] = row_h['D_mnpio']
  arg[:estado] = row_h['d_estado']
  PostalCode.find_or_create_by(arg)
  count += 1
  print "#{(100 * count) / total_rows}% \r" if total_rows > 0
end
ActiveRecord::Base.logger = old_logger # Restore logger
puts ''
puts 'Finished Inserting Postal Codes.'
puts 'Removing TempFiles'
File.delete('latest.csv')
File.delete('latest.zip')
puts 'Done.'
# --- End of copied logic ---