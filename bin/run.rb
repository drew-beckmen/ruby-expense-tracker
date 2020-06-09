require_relative './api-reader.rb'
require_relative '../config/environment'
require 'pry'
#----------------------------------------------------------
#This method retrieves all currencies supported by the app
#----------------------------------------------------------
def get_currencies(json_hash)
    all_currencies = json_hash.keys
    all_currencies << "EUR"
    all_currencies
end 

#Global constant for all the currencies we support
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


$prompt = TTY::Prompt.new

# Add methods for CLI interaction here

def greet_user 
    puts "Hi there! Welcome to Xpense!"
    answer = $prompt.yes?("Do you have an account with us?")
    answer ? find_user : create_user 
end 

def create_user
    userName = $prompt.ask("Please enter a username: ", default: ENV['USER'])
    while !User.all.find_by(userName: userName).nil? 
        puts "Sorry, this user already exists!"
        userName = $prompt.ask("Please try again with a new username: ", default: ENV['USER'])
    end 
    currency = $prompt.ask("Please enter a currency: ").upcase
    while !valid_currency?(currency)
        currency = $prompt.ask("Sorry, that's not a valid currency! Please try again: ").upcase
    end 
    User.create(userName: userName, currency: currency)
end 

def find_user
    userName = $prompt.ask("Please enter a username: ", default: ENV['USER'])
    current_user = User.all.find_by(userName: userName)
    while current_user.nil? 
        puts "Sorry, that username was not found!"
        change_mode = $prompt.yes?("Would you like to create a new user?")
        if change_mode 
            create_user
            break
        else 
            userName = $prompt.ask("Please try again: ", default: ENV['USER'])
            current_user = User.all.find_by(userName: userName)
        end 
    end 
    current_user
end

def main_menu
    $prompt.select("Welcome! Choose an option from below: ") do |menu|
        menu.choice "Enter a new expense."
        menu.choice "Update an existing expense."
        menu.choice "Delete an existing expense."
        menu.choice "Review my expenses."
        menu.choice "Currency exchange calculator."
        menu.choice "Quit the program."
    end
end 

# Master method to run whole program 
def run 
    system "clear"
    active_user = greet_user
    action = main_menu
    case action 
    when "Quit the program."
        puts "Thank you for using Xpense!"
        return 0
    end 
end 

run