class AddColumnsToOutcomeAnalysis < ActiveRecord::Migration
  def change
    add_column :outcome_analyses, :ci_upper_limit_na_comment, :text
    add_column :outcome_analyses, :p_value_description, :text
    remove_column :outcome_analyses, :description, :text
  end
end
