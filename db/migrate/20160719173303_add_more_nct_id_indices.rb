class AddMoreNctIdIndices < ActiveRecord::Migration
  def change
    add_index :sponsors, :nct_id
  end
end
