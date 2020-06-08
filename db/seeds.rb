require 'date'

User.destroy_all
Expense.destroy_all
Category.destroy_all 

u1 = User.create(userName: "andy5", currency: "EUR")
u2 = User.create(userName: "bob123", currency: "USD")
u3 = User.create(userName: "jane22", currency: "GBP")
u4 = User.create(userName: "elizabeth83", currency: "JPY")

c1 = Category.create(method_payment: "Credit Card")
c2 = Category.create(method_payment: "Debit Card")
c3 = Category.create(method_payment: "Check")
c4 = Category.create(method_payment: "Cash")


Expense.create(amount: 500, user_id: u1.id, category_id: c1.id, description: "Monthly rent", logged_on: Date.today)
Expense.create(amount: 45, user_id: u2.id, category_id: c1.id, description: "Dinner out", logged_on: Date.new(2001, 2, 3))
Expense.create(amount: 50, user_id: u3.id, category_id: c2.id, description: "Groceries", logged_on: Date.new(2020, 6, 6))
Expense.create(amount: 200, user_id: u4.id, category_id: c2.id, description: "Chromebook", logged_on: Date.new(2020, 5, 24))
Expense.create(amount: 1200.5, user_id: u4.id, category_id: c3.id, description: "iPad Pro", logged_on: Date.new(2019, 12, 25))
Expense.create(amount: 24, user_id: u1.id, category_id: c4.id, description: "Uber", logged_on: Date.new(2020, 2, 3))
Expense.create(amount: 5, user_id: u2.id, category_id: c4.id, description: "Doordash", logged_on: Date.new(2020, 1, 28))
Expense.create(amount: 2, user_id: u3.id, category_id: c2.id, description: "Vending machine snack", logged_on: Date.new(2019, 7, 8))
