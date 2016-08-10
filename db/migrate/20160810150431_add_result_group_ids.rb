class AddResultGroupIds < ActiveRecord::Migration
  def change
    add_column :baseline_measures, :result_group_id, :integer
    add_column :reported_events, :result_group_id, :integer

    add_index :baseline_measures, :result_group_id
    add_index :reported_events, :result_group_id
    add_index :outcomes, :result_group_id
  end
end
