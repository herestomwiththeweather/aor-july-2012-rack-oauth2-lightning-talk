require 'net/https'
require 'json'

class Dwolla
  def oauth2_token
    ENV['DWOLLA_OAUTH2_TOKEN']
  end

  def pin
    ENV['DWOLLA_PIN']
  end

  def destination_type
    'Email'
  end

  def path
    '/oauth/rest/accountapi/send'
  end

  def memo
    'ruby test'
  end

  def body(destination_id,amount)
    '{' + '"oauth_token": "' + oauth2_token + '",' + '"pin": "' + pin + '",' + '"destinationId": "' + destination_id + '",' + '"destinationType": "' + destination_type + '",' + '"amount": "' + amount.to_s  + '",' + '"notes": "' + memo + '"' + '}'
  end

  def send(destination_id,amount)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.post(path,body(destination_id,amount),{'Content-Type' => 'application/json', 'Accept' => 'application/json'})
  end

  def http
    @http ||= Net::HTTP.new(uri.host,uri.port)
  end

  def uri
    @uri ||= URI.parse('https://www.dwolla.com')
  end
end
