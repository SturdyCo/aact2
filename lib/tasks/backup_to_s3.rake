namespace :backup_to_s3 do
  task run: :environment do
    puts "Started S3 backup"
    # create .pgpass so we don't have to enter the password
    `bash backup_to_s3.sh`
    %x(
    pg_dump -Fc #{ENV['RDS_DB_READONLY_DBNAME']} -h #{ENV['RDS_DB_HOSTNAME']} -U #{ENV['RDS_DB_SUPER_USERNAME']} | gzip -9 | \
      s3cmd put - s3://#{ENV['S3_BUCKET_NAME']}/postgres.#{ENV['RDS_DB_READONLY_DBNAME']}.dump.#{Time.now}.gz
    )
    puts "Finished S3 backup"
  end
end
