require_relative '../config/environment'

class CLI 
    include CurrencyExchange # include module which contains methods for currency conversion
    
    $prompt = TTY::Prompt.new
    $a = Artii::Base.new 
    
    def initialize 
        run 
    end 

    # Greets a user and they can either create new account or find existing account
    def greet_user 
        welcome = $a.asciify ("Hi there ! Welcome to Xpense !")
        puts welcome.colorize(:cyan)
        answer = $prompt.yes?("Do you have an account with us?".colorize(:red))
        answer ? find_user : create_user 
    end 

    # Instantiate a new User instance with username, password, and currency
    def create_user
        userName = $prompt.ask("Please enter a username: ", default: ENV['USER'])
        while !User.all.find_by(userName: userName).nil? 
            puts "Sorry, this user already exists!"
            userName = $prompt.ask("Please try again with a new username: ", default: ENV['USER'])
        end 
        currency = get_currency("account")
        password = $prompt.mask("Please enter a password: ")
        new_user = User.new(userName: userName, currency: currency)
        new_user.password = password
        new_user.save #store it to the database
        new_user 
    end 

    # Retrieves an existing user instance - verifies with password.
    def find_user
        userName = $prompt.ask("Please enter a username: ", default: ENV['USER'])
        current_user = User.all.find_by(userName: userName)
        while current_user.nil? 
            puts "Sorry, that username was not found!"
            change_mode = $prompt.yes?("Would you like to create a new user?")
            if change_mode 
                create_user
                return 0 #exit this function
            else 
                userName = $prompt.ask("Please try again: ", default: ENV['USER'])
                current_user = User.all.find_by(userName: userName)
            end 
        end
        
        # Add password validation
        user_password = $prompt.mask("Please enter the password for your account: ")
        while !current_user.authenticate(user_password)
            user_password = $prompt.mask("Incorrect password. Try again: ")
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

    # Allow user to enter a valid currency either by selecting from a list or entering it themselves.
    def get_currency(base_or_target)
        currency = $prompt.ask("What is the three letter code for your #{base_or_target} currency? Want to select from a list? Press 1: ").upcase
        case currency
        when "1"
            currency = $prompt.select("Choose a currency: ", CurrencyExchange::SUPPORTED_CURRENCIES).upcase
        else 
            while !CurrencyExchange.valid_currency?(currency)
                puts "Sorry, #{currency} is not a supported currency."
                currency = $prompt.ask("Please enter a valid 3 letter code for your #{base_or_target} currency: ").upcase
            end 
        end 
        currency
    end 

    # Ensures that the amount can be converted without throwing error
    def get_amount_conversion
        convert_to_float
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
        puts "#{amount} #{base_currency} is #{CurrencyExchange.convert_currency(base_currency, target_currency, amount).round(2)} #{target_currency}".colorize(:red)
        puts "Thank you for using the currency exchange calculator."
        puts "Returning you to the main menu..."
    end 

    def enter_date
        months = Array.new(Date::MONTHNAMES)
        months.shift(1) #Date::MONTHNAMES starts with nil so months can be indexed 1-12 rather to 0-11 but we want to get rid of nil.
        str_month = $prompt.select("Choose a month: ", months)
        int_month = months.index(str_month) + 1 #January would be index 0, we want index 1.
        day = $prompt.ask("Enter a day: ")
        day = Integer(day) rescue nil
        year = $prompt.ask("Enter a year: ")
        year = Integer(year) rescue nil
        [year, int_month, day]
    end 
    # Checks whether a date is valid (including checking if its in the future!). Returns true if date is not valid, false if valid.
    def invalid_date(arr_date)
        arr_date[0].nil? || #if the year failed to be converted to an integer
        arr_date[2].nil? || #if the day failed to be converted to an integer
        arr_date[0] > Date.today.year || 
        (arr_date[0] == Date.today.year && arr_date[1] > Date.today.month) || 
        (arr_date[0] == Date.today.year && arr_date[1] == Date.today.month && arr_date[2] > Date.today.day) || 
        !Date.valid_date?(arr_date[0], arr_date[1], arr_date[2])
    end 

    # allows user to select a date (either today, yesterday, or further back in time)
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
            while invalid_date(arr_date)
                puts "Sorry, not a valid date. Please try entering again: "
                arr_date = enter_date
            end 
            date = Date.new(arr_date[0], arr_date[1], arr_date[2])
        end 
        date
    end 

    # Ask user for numerical input until they input something valid
    def convert_to_float
        amount = $prompt.ask("Please enter an amount: ")
        amount = Float(amount) rescue nil 
        while amount.nil? 
            amount = $prompt.ask("Sorry, invalid amount to convert. Please try again: ")
            amount = Float(amount) rescue nil 
        end 
        amount
    end

    def get_amount(user)
        amount = convert_to_float
        check_currency = $prompt.yes?("Is this in your base currency (#{user.currency})? ")
        if !check_currency
            currency = $prompt.ask("What is the three letter currency code for this expense? Want to select from a list? Press 1: ").upcase
            case currency
                when "1"
                    currency = $prompt.select("Choose a currency: ", CurrencyExchange::SUPPORTED_CURRENCIES).upcase
                else 
                    while !CurrencyExchange.valid_currency?(currency)
                        puts "Sorry, #{currency} is not a supported currency."
                        currency = $prompt.ask("Please enter a valid 3 letter code for this expense: ").upcase
                    end 
            end 
            amount = CurrencyExchange.convert_currency(currency, user.currency, amount)
        end
        amount
    end 

    # Allows a user to select an existing method of payment or enter a new one.
    def get_payment_method(user)
        user.payments.reload
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

    # Allows a user to enter expense description - cannot be nil
    def get_description 
        description = $prompt.ask("Please briefly describe this expense: ")
        while description.nil? 
            puts "Sorry, not a valid description."
            description = $prompt.ask("Please try again: ")
        end 
        description
    end 

    # Calls on helper methods to get each component of a new expense
    def create_expense(user)
        date = select_date
        amount = get_amount(user)
        description = get_description
        p = get_payment_method(user)
        Expense.create(amount: amount, user_id: user.id, payment_id: p.id, description: description, logged_on: date)
        # Reload both payments and expenses after creating a new expense
        user.expenses.reload 
        user.payments.reload # must also reload payments in the case that a new payment is logged!
    end 

    def display_expenses(list_expenses) #formats the array of hashes so that Formatador can display it
        if list_expenses.empty?
            puts "Sorry, no expenses found!".colorize(:red)
            return 0
        end 
        arr_hashes = list_expenses.map {|expense| expense.attributes}
        arr_hashes.map{ |expense| 
            expense.delete("id") # we don't need the id of each expense
            expense.delete("user_id") # nor do we need the user it belongs to 
            expense["payment_method"] = expense.delete "payment_id" #change name of the column in the table
            expense["payment_method"] = Payment.find(expense["payment_method"]).method_payment #change value from unique id to corresponding payment method
        }
        Formatador.display_table(arr_hashes) #display the table
    end 

    # Displays expenses according to timeframe specified by the user. 
    def review_expenses(user)
        review_time = $prompt.select("What expenses would you like to review?") do |menu|
            menu.choice "All expenses"
            menu.choice "Expenses from the past year."
            menu.choice "Expenses from the past month."
            menu.choice "Expenses from the past week."
            menu.choice "Expenses by payment method."
        end 
        case review_time 
        when "All expenses"
            display_expenses(user.expenses)
            puts "Total lifetime expenses are #{user.total_expenses} #{user.currency}".colorize(:red)
        when "Expenses from the past year."
            display_expenses(user.expenses_this_year)
            puts "Total expenses from the past year are #{user.total_year_expenses} #{user.currency}".colorize(:red)
        when "Expenses from the past month."
            display_expenses(user.expenses_this_month)
            puts "Total expenses from the past month are #{user.total_month_expenses} #{user.currency}".colorize(:red)     
        when "Expenses from the past week."
            display_expenses(user.expenses_this_week)
            puts "Total expenses from the past week are #{user.total_week_expenses} #{user.currency}".colorize(:red)
        when "Expenses by payment method."
            payment = $prompt.select("Pick a payment method: ", user.payments_list)
            display_expenses(user.expenses_by_payment_method(payment))
        end 
    end 

    # Displays all transactions that can be updated or deleted. 
    def choose_previous_transaction(user, operation)
        expense_descriptions = user.expenses.map{|expense| "#{expense.description} - #{expense.logged_on}"}  
        expense_descriptions.unshift("Back to main menu")
        expense_to_delete = $prompt.select("Choose an expense to #{operation}: ", expense_descriptions)
        if expense_to_delete == "Back to main menu"
            return 0
        end 
        expense_to_delete.split(" - ")
    end 
        
    # Allows a user to delete an expense based on description & date
    def delete_expense(user)
        if user.expenses.empty?
            puts "Sorry, no expenses found!".colorize(:red)
            return 0
        end
        expense_to_delete = choose_previous_transaction(user, "delete")
        return 0 if expense_to_delete == 0
        description, date = expense_to_delete
        Expense.find_by(description: description, logged_on: date, user_id: user.id).destroy
        user.expenses.reload
    end

    # Allows a user to update expense based on description & date. 
    # They can update any of the fields of an expense (date, amount, description, payment method)
    def update_expense(user)
        expense_to_update = choose_previous_transaction(user, "update")
        return 0 if expense_to_update == 0 #if expense_to_update is zero, that means there are no expenses for this user. 
        description, date = expense_to_update #parallel assignment for the array returned by the method choose_previous_transaction
        expense_to_update = Expense.find_by(description: description, logged_on: date, user_id: user.id)
        category_to_update = $prompt.multi_select("What would you like to update?", ["amount", "description", "logged_on", "payment_method"])
        amount, logged_on, payment_method, description = expense_to_update.amount, expense_to_update.logged_on, expense_to_update.payment, expense_to_update.description 
        category_to_update.each do |change|
            case change 
            when "amount"
                puts "The original amount was #{expense_to_update.amount}"
                amount = get_amount(user)
            when "logged_on"
                puts "The original date was #{expense_to_update.logged_on}"
                logged_on = select_date
            when "payment_method"
                puts "The original payment method was #{expense_to_update.payment.method_payment}"
                payment_method = get_payment_method(user) #this variable will a Payment object.
            when "description"
                puts "The original description was #{expense_to_update.description}"
                description = get_description
            end 
        end
        expense_to_update.update(amount: amount, description: description, logged_on: logged_on, payment_id: payment_method.id)
        user.expenses.reload
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
            when "Delete an existing expense."
                delete_expense(active_user)
            when "Update an existing expense."
                update_expense(active_user)
            when "Review my expenses."
                review_expenses(active_user)
            when "Currency exchange calculator."
                currency_exchange
            when "Quit the program."
                goodbye = $a.asciify ("Thanks for using Xpense !")
                puts goodbye.colorize(:cyan)
                return 0
            end
        end 
    end 
end 

CLI.new