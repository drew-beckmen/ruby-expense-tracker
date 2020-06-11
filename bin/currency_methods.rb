# Contains all methods for performing operations on data returned by 
# the API
module CurrencyExchange

    #----------------------------------------------------------
    #This method retrieves all currencies supported by the app
    #----------------------------------------------------------
    def self.get_currencies(json_hash)
        all_currencies = json_hash.keys
        all_currencies << "EUR"
        all_currencies
    end 

    #Global constant for all the currencies we support
    SUPPORTED_CURRENCIES = self.get_currencies(GetData.new.get_rates)

    #------------Methods for Converting Currency----------------
    def self.valid_currency?(symbol)
        SUPPORTED_CURRENCIES.include?(symbol)
    end 

    def self.find_target_rate(target, rates)
        rates[target]
    end 

    def self.convert_to_target(base, target, amount, rates)
        euro_value = amount.to_f * (1 / rates[base])
        euro_value * find_target_rate(target, rates)
    end

    def self.convert_currency(base, target, amount)
        rates = GetData.new.get_rates
        if base == "EUR"
            return amount * find_target_rate(target, rates)
        else 
            return convert_to_target(base, target, amount, rates)
        end 
    end
    #---------------------------------------------------------------
end 