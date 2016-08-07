class AddResultGroupIdToParticipantFlow < ActiveRecord::Migration
  def change
    add_column :participant_flows, :result_group_id, :integer
  end
end
