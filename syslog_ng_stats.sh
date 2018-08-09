#!/bin/bash
#author Bryant Treacle
#date 11 May 18
#purpose: This script will gather syslog-ng stats on all Security Onion Sensors which are Salt Minions and saving the results to a csv.

sudo salt '*' cmd.run 'syslog-ng-ctl stats | grep d_logstash'  --output text --out-file syslog-ng-stats.csv
sleep 5
# Formatting the Output into proper columns
sed -i -e 's/: /,/g' syslog-ng-stats.csv
sed -i -e 's/;/,/g' syslog-ng-stats.csv
sed -i -e 's/,,/,,,/g' syslog-ng-stats.csv
sed -i -e 's/destination/dst.tcp/g' syslog-ng-stats.csv

#converting csv to JSON and sending it to Logstash

while read f1
do
curl -XPUT -H "content-type: application/json" 'http://localhost:6000/' -d "{\"message\":\"$f1\"}"
done < syslog-ng-stats.csv


