#!/bin/bash
#author Bryant Treacle
#date 11 May 18
#purpose: This script will gather syslog-ng stats on all Security Onion Sensors which are Salt Minions and saving the results to a csv.


#Get syslong-ng stats from sensors

sudo salt '*' cmd.run 'syslog-ng-ctl stats | grep d_logstash'  --output text --out-file syslog-ng-stats.csv
sleep 5

# Formatting the Output into proper columns
sed -i -e 's/:/,/g' syslog-ng-stats.csv
sed -i -e 's/;/,/g' syslog-ng-stats.csv
sed -i -e 's/,,/,,,/g' syslog-ng-stats.csv
sed -i -e 's/destination/dst.tcp/g' syslog-ng-stats.csv

#converting csv to JSON with field name and sending it to Logstash

while IFS=',' read f1 f2 f3 f4 f5 f6 f7 f8 f9
do
curl -XPUT -H "content-type: application/json" 'http://localhost:6000/' -d "{\"sensor_name\":\"$f1\", \"syslog_ng_dst_proto\":\"$f2\", \"syslog_ng_destination\":\"$f3\", \"protocol\":\"$f4\",  \"destination_ip\":\"$f5\", \"destination_port\":\"$f6\", \"syslog_ng_remove\":\"$f7\", \"syslog_ng_action\":\"$f8\", \"syslog_ng_value\":\"$f9\" }"
done < syslog-ng-stats.csv
#Cleaning up file
rm syslog-ng-stats.csv
