require 'warden'

module Authentication
  class TokenStrategy < Warden::Strategies::Base
    def valid?
      access_token.present?
    end

    def authenticate!
      if !ENV['VALIDATE_HEADER'] || !ENV['VALIDATE_HEADER_VALUE']
        fail! 'Authentication configuration error'
        return
      end

      if access_token == ENV['VALIDATE_HEADER_VALUE']
        success! access_token
      else
        fail! 'Unauthorized'
      end
    end

    private

    def access_token
      header_name = ENV['VALIDATE_HEADER']&.upcase&.gsub('-', '_')
      return nil unless header_name

      @access_token ||= request.get_header("HTTP_#{header_name}")
    end
  end
end
