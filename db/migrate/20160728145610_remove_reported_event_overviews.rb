class RemoveReportedEventOverviews < ActiveRecord::Migration
  def change
    drop_table :reported_event_overviews
  end
end
