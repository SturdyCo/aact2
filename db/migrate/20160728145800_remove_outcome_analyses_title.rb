class RemoveOutcomeAnalysesTitle < ActiveRecord::Migration
  def change
    remove_column :outcome_analyses, :title
  end
end
