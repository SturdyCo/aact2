class AddParticipantFlowIdToResultGroup < ActiveRecord::Migration
  def change
    add_column :result_groups, :participant_flow_id, :integer
  end
end
