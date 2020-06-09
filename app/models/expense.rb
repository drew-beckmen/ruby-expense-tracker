class Expense < ActiveRecord::Base
    belongs_to :user 
    belongs_to :payment

    # Takes in an instance of expense from the user and deletes it.
    def delete_expense
        self.destroy
    end


end 
