#!/bin/bash
credentials=`cat /opt/voicetech/config/mysql.conf`
user=`echo $credentials | jq '.user' | cut -d'"' -f2`
pass=`echo $credentials | jq '.pass' | cut -d'"' -f2`
base=`echo $credentials | jq '.base' | cut -d'"' -f2`
host=`echo $credentials | jq '.host' | cut -d'"' -f2`

# copy profile
#cp examples/unimrcpclient.xml /usr/local/unimrcp/conf/
#cp examples/tts.xml /usr/local/unimrcp/conf/client-profiles/

# cp mrcp.conf
#cp examples/mrcp.conf /etc/asterisk/mrcp.conf

# replace function __phoneGetIVR()
#zcat __phoneGetIVR.sql | mysql -u $user --password=$pass -h $host $base

# generate dialplan
#mysql -u $user --password=$pass -h $host $base -e  "update updated set is_updated=2;"
