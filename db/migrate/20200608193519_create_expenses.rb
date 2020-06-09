class CreateExpenses < ActiveRecord::Migration[5.2]
  def change
    create_table :expenses do |t|
      t.float :amount 
      t.integer :user_id
      t.integer :payment_id
      t.string :description 
      t.date :logged_on
    end 
  end
end
