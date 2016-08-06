class RenameGroupsToResultGroups < ActiveRecord::Migration
  def change
    rename_table :groups, :result_groups
  end
end
