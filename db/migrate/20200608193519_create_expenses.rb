class CreateExpenses < ActiveRecord::Migration[5.2]
  def change
    create_table :expenses do |t|
      t.float :amount 
      t.integer :user_id
      t.integer :category_id
      t.string :description 
      t.datetime :logged_at
    end 
  end
end
