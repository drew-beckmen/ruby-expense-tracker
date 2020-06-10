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
    answer = $prompt.yes?("Do you have an account with us?".colorize(:red))
    answer ? find_user : create_user 
end 

def create_user
    userName = $prompt.ask("Please enter a username: ", default: ENV['USER'])
    while !User.all.find_by(userName: userName).nil? 
        puts "Sorry, this user already exists!"
        userName = $prompt.ask("Please try again with a new username: ", default: ENV['USER'])
    end 
    currency = $prompt.ask("Please enter a currency. We support Crypto! ").upcase
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
    $prompt.select("Choose an option from below: ") do |menu|
        menu.choice "Enter a new expense."
        menu.choice "Update an existing expense."
        menu.choice "Delete an existing expense."
        menu.choice "Review my expenses."
        menu.choice "Currency exchange calculator."
        menu.choice "Quit the program."
    end
end 

def get_currency(base_or_target)
    currency = $prompt.ask("What is the three letter code for your #{base_or_target} currency? Want to select from a list? Press 1: ")
    case currency
    when "1"
        currency = $prompt.select("Choose a currency: ", $SUPPORTED_CURRENCIES)
    else 
        while !valid_currency?(currency)
            puts "Sorry, #{currency} is not a supported currency."
            currency = $prompt.ask("Please enter a valid 3 letter code for your #{base_or_target} currency: ")
        end 
    end 
    currency
end 

def get_amount_conversion
    amount = $prompt.ask("Please enter an amount of money to convert: ")
    amount.to_f  #may want to come back to this later to do some error handling if it can't be converted. 
end 


def progress_bar
    total    = 1000
    progress = Formatador::ProgressBar.new(total){|b| b.opts[:color] = "green" }
    1000.times do
        progress.increment
        sleep 0.0001
    end
end 

def currency_exchange
    puts "Welcome to the currency exchange calculator!".colorize(:red)
    puts "We use live forex rates fetched from a trusted API!"
    base_currency = get_currency("base")
    amount = get_amount_conversion
    target_currency = get_currency("target")
    progress_bar
    puts ""
    puts "#{amount} #{base_currency} is #{convert_currency(base_currency, target_currency, amount).round(2)} #{target_currency}"
    puts "Thank you for using the currency exchange calculator."
    puts "Returning you to the main menu..."
end 

def enter_date
    months = Array.new(Date::MONTHNAMES)
    months.shift(1)
    str_month = $prompt.select("Choose a month: ", months)
    int_month = months.index(str_month) + 1
    day = $prompt.ask("Enter a day: ")
    day = day.to_i #come back to this - error handling for conversion
    year = $prompt.ask("Enter a year: ")
    year = year.to_i 
    [year, int_month, day]
end 
# Checks whether a date is valid (including checking if its in the future!). Returns true if date is not valid, false if valid.
def invalid_date(arr_date)
    arr_date[0] > Date.today.year || 
    (arr_date[0] == Date.today.year && arr_date[1] > Date.today.month) || 
    (arr_date[0] == Date.today.year && arr_date[1] == Date.today.month && arr_date[2] > Date.today.day) || 
    !Date.valid_date?(arr_date[0], arr_date[1], arr_date[2])
end 

def select_date
    date = $prompt.select("When did you incur this expense?") do |menu|
        menu.choice "Today"
        menu.choice "Yesterday"
        menu.choice "Further back in time"
    end
    case date 
    when "Today"
        date = Date.today 
    when "Yesterday"
        date = Date.today - 1
    when "Further back in time"
        arr_date = enter_date
        # binding.pry
        while invalid_date(arr_date)
            puts "Sorry, not a valid date. Please try entering again: "
            arr_date = enter_date
        end 
        date = Date.new(arr_date[0], arr_date[1], arr_date[2])
    end 
    date
end 

def get_amount(user)
    amount = $prompt.ask("Please enter an amount: ")
    amount = amount.to_f #come back to error handling later
    check_currency = $prompt.yes?("Is this in your base currency (#{user.currency})? ")
    if !check_currency
        currency = $prompt.ask("What is the three letter currency code for this expense? Want to select from a list? Press 1: ")
        case currency
            when "1"
                currency = $prompt.select("Choose a currency: ", $SUPPORTED_CURRENCIES)
            else 
                while !valid_currency?(currency)
                    puts "Sorry, #{currency} is not a supported currency."
                    currency = $prompt.ask("Please enter a valid 3 letter code for this expense: ")
                end 
        end 
        amount = convert_currency(currency, user.currency, amount)
    end
    amount
end 

def get_payment_method(user)
    payment_methods = user.payments_list 
    payment_methods << "Add a new method of payment"
    method = $prompt.select("Choose a payment method: ", payment_methods)
    case method 
    when "Add a new method of payment"
        new_method = $prompt.ask("Enter your new payment method")
        p = Payment.create(method_payment: new_method)
    else 
        p = Payment.find_by(method_payment: method)
    end 
    p
end 

def create_expense(user)
    date = select_date
    amount = get_amount(user)
    description = $prompt.ask("Please briefly describe this expense: ")
    p = get_payment_method(user)
    Expense.create(amount: amount, user_id: user.id, payment_id: p.id, description: description, logged_on: date)
end 

# Master method to run whole program 
def run 
    system "clear"
    active_user = greet_user
    while true 
        action = main_menu
        case action
        when "Enter a new expense."
            create_expense(active_user)
        when "Currency exchange calculator."
            currency_exchange
        when "Quit the program."
            puts "Thank you for using Xpense!"
            return 0
        end
    end 
end 

run

# run