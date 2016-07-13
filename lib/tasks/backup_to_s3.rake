namespace :backup_to_s3 do
  task run: :environment do
    # create .pgpass so we don't have to enter the password
    entry = "#{ENV['RDS_DB_HOSTNAME']}:*:*:#{ENV['RDS_DB_SUPER_USERNAME']}:#{ENV['RDS_DB_SUPER_PASSWORD']}"
    `echo '#{entry}' > ~/.pgpass;
      chmod 0600 ~/.pgpass;
      bash backup_to_s3.sh -v`
  end
end
