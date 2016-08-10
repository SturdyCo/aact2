class AddColumnsToParticipantFlow < ActiveRecord::Migration
  def change
    add_column :participant_flows, :group_title, :text
    add_column :participant_flows, :group_description, :text
  end
end
