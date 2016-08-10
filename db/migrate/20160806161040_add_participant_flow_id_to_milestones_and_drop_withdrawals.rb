class AddParticipantFlowIdToMilestonesAndDropWithdrawals < ActiveRecord::Migration
  def change
    add_column :milestones, :participant_flow_id, :integer
    add_column :drop_withdrawals, :participant_flow_id, :integer
  end
end
