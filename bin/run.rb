require './api-reader.rb'
require 'pry'
#----------------------------------------------------------
# This method retrieves all currencies supported by the app
#----------------------------------------------------------
def get_currencies(json_hash)
    all_currencies = json_hash.keys
    all_currencies << "EUR"
    all_currencies
end 

# Global constant for all the currencies we support
$SUPPORTED_CURRENCIES = get_currencies(GetData.new.get_rates)

#------------Methods for Converting Currency----------------
def valid_currency?(symbol)
    $SUPPORTED_CURRENCIES.include?(symbol)
end 

def find_target_rate(target, rates)
    rates[target]
end 

def convert_to_target(base, target, amount, rates)
    euro_value = amount.to_f * (1 / rates[base])
    euro_value * find_target_rate(target, rates)
end

def convert_currency(base, target, amount)
    rates = GetData.new.get_rates
    if base == "EUR"
        return amount * find_target_rate(target, rates)
    else 
        return convert_to_target(base, target, amount, rates)
    end 
end
#---------------------------------------------------------------

require_relative '../config/environment'

$prompt = TTY::Prompt.new

# Add methods for CLI interaction here


