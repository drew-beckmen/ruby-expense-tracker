# Extending the date class (https://stackoverflow.com/questions/42712101/if-date-is-less-than-a-week-ago-conditional)
class Date 
    def within_last?(duration, date = Date.current)
        between?(date - duration, date)
    end
end 

class User < ActiveRecord::Base
    has_many :expenses
    has_many :payments, through: :expenses

    # Returns the total expenses logged in this platform by a specific User instance.
    def total_expenses
        sum_expenses(self.expenses)
    end

    # Returns array of this user's expenses from today to today - duration days ago.
    def get_specific_expenses(duration)
        self.expenses.select {|expense| expense.logged_on.within_last?(duration)}
    end

    # Returns all expense instances from past week.
    def expenses_this_week 
        self.get_specific_expenses(7)
    end 

    # Returns total expenses logged by this user in the previous week (7 days).
    def total_week_expenses
        sum_expenses(expenses_this_week)
    end 

    # Returns all expense instances from past month.
    def expenses_this_month 
        self.get_specific_expenses(30)
    end 

    # Returns total expenses logged by this user in the previous month (30 days).
    def total_month_expenses
        sum_expenses(expenses_this_month)
    end 

    #  Returns all expense instances from past year.
    def expenses_this_year 
        self.get_specific_expenses(365)
    end 

    # Returns total expenses logged by this user in the previous year (365 days).
    def total_year_expenses
        sum_expenses(expenses_this_year)
    end 

    # Given an input of a year, return an array of all the expenses.
    def expenses_given_year(year)
        self.expenses.select {|expense| expense.logged_on.year == year}
    end

    # Returns a list of all payment methods that this user has used.
    def payments_list
        self.payments.map{|payment| payment.method_payment}.uniq
    end

    # Returns summary of expenses by payment methods.
    def expenses_by_payment_method(method_payment)
        self.expenses.select {|expense| expense.payment.method_payment == method_payment}
    end

    def payments_this_week
        payments_this_period(expenses_this_week)
    end 

    def payments_this_month 
        payments_this_period(expenses_this_month)
    end 

    def payments_this_year
        payments_this_period(expenses_this_year)
    end 

    # Define a private instance method that should only be used internally to sum
    # instances of Expense for a given user.
    private 
    def sum_expenses(list_expenses)
        list_expenses.inject(0) {|sum, expense| sum + expense.amount}
    end 

    # Returns a hash where key is payment method and value is amount spent on 
    # that payment method within the last week
    def payments_this_period(expenses)
        payment_records = {}
        expenses.each do |expense|
            if payment_records[expense.payment.method_payment].nil? 
                payment_records[expense.payment.method_payment] = expense.amount
            else 
                payment_records[expense.payment.method_payment] += expense.amount
            end 
        end 
        payment_records
    end
end 