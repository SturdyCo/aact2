class TableExportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'table_export'

  def perform(delimiter: ',')
    exporter = TableExporter.new
    exporter.run(delimiter: delimiter, should_upload_to_s3: true)
  end
end
