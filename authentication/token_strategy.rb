require 'warden'

module Authentication
  class TokenStrategy < Warden::Strategies::Base
    def valid?
      access_token.present?
    end

    def authenticate!
      if access_token == ENV['VALIDATE_HEADER_VALUE']
        success! access_token
      else
        fail! 'Unathorized'
      end
    end

    private

    def access_token
      @access_token ||= request.get_header("HTTP_#{ENV['VALIDATE_HEADER']}")
    end
  end
end
