require 'date'
require 'bcrypt'
User.destroy_all
Expense.destroy_all
Payment.destroy_all 

u1 = User.create(userName: "andy5", currency: "EUR", password_digest: BCrypt::Password.create('password'))
u2 = User.create(userName: "bob123", currency: "USD", password_digest: BCrypt::Password.create('password'))
u3 = User.create(userName: "jane22", currency: "GBP", password_digest: BCrypt::Password.create('password'))
u4 = User.create(userName: "elizabeth83", currency: "JPY", password_digest: BCrypt::Password.create('password'))

c1 = Payment.create(method_payment: "Credit Card")
c2 = Payment.create(method_payment: "Debit Card")
c3 = Payment.create(method_payment: "Check")
c4 = Payment.create(method_payment: "Cash")

Expense.create(amount: 500, user_id: u1.id, payment_id: c1.id, description: "Monthly rent", logged_on: Date.today)
Expense.create(amount: 45, user_id: u2.id, payment_id: c1.id, description: "Dinner out", logged_on: Date.new(2001, 2, 3))
Expense.create(amount: 50, user_id: u3.id, payment_id: c2.id, description: "Groceries", logged_on: Date.new(2020, 6, 6))
Expense.create(amount: 200, user_id: u4.id, payment_id: c2.id, description: "Chromebook", logged_on: Date.new(2020, 5, 24))
Expense.create(amount: 1200.5, user_id: u4.id, payment_id: c3.id, description: "iPad Pro", logged_on: Date.new(2019, 12, 25))
Expense.create(amount: 24, user_id: u1.id, payment_id: c4.id, description: "Uber", logged_on: Date.new(2020, 2, 3))
Expense.create(amount: 5, user_id: u2.id, payment_id: c4.id, description: "Doordash", logged_on: Date.new(2020, 1, 28))
Expense.create(amount: 2, user_id: u3.id, payment_id: c2.id, description: "Vending machine snack", logged_on: Date.new(2019, 7, 8))
