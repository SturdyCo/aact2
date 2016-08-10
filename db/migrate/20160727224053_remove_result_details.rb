class RemoveResultDetails < ActiveRecord::Migration
  def change
    drop_table :result_details
  end
end
