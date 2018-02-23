#!/bin/sh

# Check that the environment variable has been set correctly
if [ -z "$SECRETS_BUCKET_NAME" ]; then
  echo >&2 'error: missing SECRETS_BUCKET_NAME environment variable'
  exit 1
fi

aws configure set s3.signature_version s3v4

# Load the S3 file contents into the environment variables
eval $(aws s3 cp s3://${SECRETS_BUCKET_NAME}/${APP_NAME}.secrets - | sed 's/ = /="/' | sed 's/$/"/' | sed 's/^/export /')

# Setup s3fs
echo "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" > /etc/passwd-s3fs
chmod 600 /etc/passwd-s3fs

# Add a virtual user fot vsftpd
cd /etc/vsftpd
echo "$FTP_USER" > vusers.txt
echo "$FTP_PASSWORD" >> vusers.txt
db_load -T -t hash -f vusers.txt vsftpd-virtual-user.db
chmod 600 vsftpd-virtual-user.db # make it not global readable
rm vusers.txt

service vsftpd start

s3fs -o passwd_file=/etc/passwd-s3fs,use_cache=/tmp,use_path_request_style,url=http://s3-ap-southeast-1.amazonaws.com,uid=1000,gid=65534 $S3_BUCKET /home/vsftpd/$FTP_USER

exec "$@"
