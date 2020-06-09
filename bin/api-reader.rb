require 'net/http'
require 'open-uri'
require 'json'

class GetData 
    URL = "http://data.fixer.io/api/latest?access_key=e339da124f5ffb969bd4e5221b33236c"

    def get_data 
        uri = URI.parse(URL)
        response = Net::HTTP.get_response(uri)
        response.body 
    end 

    def get_rates
        rates = JSON.parse(self.get_data)
        rates["rates"]
    end 
end