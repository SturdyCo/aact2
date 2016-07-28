class DropWithdrawalReasonToTitle < ActiveRecord::Migration
  def change
    rename_column :drop_withdrawals, :reason, :title
  end
end
