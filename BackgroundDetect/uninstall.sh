#!/bin/bash
credentials=`cat /opt/voicetech/config/mysql.conf`
user=`echo $credentials | jq '.user' | cut -d'"' -f2`
pass=`echo $credentials | jq '.pass' | cut -d'"' -f2`
base=`echo $credentials | jq '.base' | cut -d'"' -f2`
host=`echo $credentials | jq '.host' | cut -d'"' -f2`

# noload => app_talkdetect.so
zcat load_app_talkdetect.sql.gz | mysql -u $user --password=$pass -h $host $base
# exten = s,n,Background(/usr/share/asterisk/sounds/cache/${sfile},100,10,500)
zcat __phoneGetIVR.sql.gz | mysql -u $user --password=$pass -h $host $base
# generate conf
mysql -u $user --password=$pass -h $host $base -e  "update updated set is_updated=2;"
