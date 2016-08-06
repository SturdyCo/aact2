class RenameGroupsToResultGroups < ActiveRecord::Migration
  def change
    rename_table :groups, :result_groups
    remove_column :drop_withdrawals, :group_id
    remove_column :milestones, :group_id
    rename_column :outcomes, :group_id, :result_group_id
  end
end
