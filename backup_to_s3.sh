#!/bin/bash

echo 'Starting database backup to S3!'

backupTime=`date +%Y%m%d-%H:%M`
S3Bucket=aact2
RDSHostname=aact2-main.cbj0v72pdrrv.us-east-1.rds.amazonaws.com
RDSUsername=garrettqmartin
RDSDatabaseName=aact2

pg_dump -Fc ${RDSDatabaseName} -h ${RDSHostname} -U ${RDSUsername} --no-password | gzip -9 | \
  s3cmd -c ./.s3cfg put - s3://${S3Bucket}/postgres.${RDSDatabaseName}.dump.${backupTime}.gz

