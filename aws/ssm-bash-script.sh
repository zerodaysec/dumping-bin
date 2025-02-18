#!/bin/bash

# Pull some files from AWS S3
aws s3 sync ${PIPELINE_BUCKET}/${ENVIRONEMNT}/sql_upload ./sql

# Setup user
SSM_DB_USER=$(AWS_DEFAULT_REGION=us-east-1 aws ssm get-parameter --name "/prod/user" --with-decryption | jq -r .Parameter.Value)

# Setup db name
SSM_DB_NAME=$(AWS_DEFAULT_REGION=us-east-1 aws ssm get-parameter --name "/prod/user" --with-decryption | jq -r .Parameter.Value)

# Setup db_host
SSM_DB_HOST=$(AWS_DEFAULT_REGION=us-east-1 aws ssm get-parameter --name "/prod/host" --with-decryption | jq -r .Parameter.Value)

if [ -f ./sql/Users.sql ]; then
    # Run command using the values from SSM Param Store
	psql \
        -h $SSM_DB_HOST \
        -U $SSM_DB_USER \
        -d $SSM_DB_NAME \
        -a -f ./sql/Users.sql
fi