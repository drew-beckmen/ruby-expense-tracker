require 'net/http'
require 'open-uri'
require 'json'
# require 'figaro'
require 'dotenv/load'
require 'pry'

class GetData 
    key = ENV['FIXER_API_KEY']
    binding.pry
    URL = "http://data.fixer.io/api/latest?access_key=#{key}"

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

# x = GetData.new
# puts x.get_rates
# binding.pry
# 0