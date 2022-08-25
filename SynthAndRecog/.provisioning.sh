#!/bin/bash
credentials=`cat /opt/voicetech/config/mysql.conf`
user=`echo $credentials | jq '.user' | cut -d'"' -f2`
pass=`echo $credentials | jq '.pass' | cut -d'"' -f2`
base=`echo $credentials | jq '.base' | cut -d'"' -f2`
host=`echo $credentials | jq '.host' | cut -d'"' -f2`

# server_ip=10.3.0.9
# client_ip=10.3.0.19
mysql -u $user --password=$pass -h $host $base -e  "UPDATE connectors SET param = REPLACE(param, '&i=any','') WHERE type = 'SpeechRecognitionConnector';"
mysql -u $user --password=$pass -h $host $base -e  "UPDATE connectors SET param = REPLACE(param, 'b=1&','') WHERE type = 'SpeechRecognitionConnector';"
envsubst < examples/mrcpconnectors.conf > /etc/asterisk/mrcpconnectors.conf
envsubst < examples/tts.xml > /usr/local/unimrcp/conf/client-profiles/tts.xml
zcat _phoneGetIVR.sql | mysql -u $user --password=$pass -h $host $base
mysql -u $user --password=$pass -h $host $base -e  "update updated set is_updated=2;"
firewall-cmd --zone=public --permanent --add-port=38000-39000/udp --add-port=8062/tcp && firewall-cmd --reload