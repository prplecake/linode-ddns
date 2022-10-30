#!/usr/bin/env -S bash -xe

read -p "Domain name: " domainName
if [ $domainName ]; then
  echo $domainName
else 
  exit 1
fi
read -p "Record name: " recordName
if [ $recordName ]; then
  echo $recordName
else 
  exit 1
fi

cat << EOF > .env
domainName="$domainName"
recordName="$recordName"
EOF
