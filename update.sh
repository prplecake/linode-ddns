#!/usr/bin/env bash -xe

ROOTDIR=$(dirname "$(readlink -f "$0")")
if [ -f "$ROOTDIR/.env" ]; then
  source "$ROOTDIR/.env"
else
  "$ROOTDIR/setup.sh"
  source "$ROOTDIR/.env"
fi

currentPublicIp=$(curl -s https://ipv4.wtfismyip.com/text)

domainId=$(linode-cli domains list --domain $domainName --no-headers --text --format id)
recordId=$(linode-cli domains records-list $domainId --text --delimiter ',' | grep $recordName | cut -f1 -d,)
if [ -z $recordId ]; then
  # if $recordId is empty, the record probably doesn't exist. let's
  # create it.
  linode-cli domains records-create $domainId --type A --name $recordName --target $currentPublicIp --ttl $((5*60))
  exit 0
fi

currentRecordIp=$(linode-cli domains records-view $domainId $recordId --no-headers --text --format target)

if [ "$currentRecordIp" = "$currentPublicIp" ]; then exit; fi

# IPs are not the same, let's update the record
linode-cli domains records-update $domainId $recordId --target $currentPublicIp > /dev/null
exit
