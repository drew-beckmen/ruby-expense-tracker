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