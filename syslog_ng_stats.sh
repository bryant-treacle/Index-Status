#!/bin/bash
#author Bryant Treacle
#date 11 May 18
#purpose: This script will gather syslog-ng stats on all Security Onion Sensors which are Salt Minions and saving the results to a csv.

sudo salt '*' cmd.run 'syslog-ng-ctl stats | grep d_logstash'  --output text --out-file syslog-ng-stats.csv

# Formatting the Output into proper columns
sed -i -e 's/: /,/g' syslog-ng-stats.csv
sed -i -e 's/;/,/g' syslog-ng-stats.csv
sed -i -e 's/,,/,,,/g' syslog-ng-stats.csv

# Moving file to Logstash directory to be ingested.
sudo mv syslog-ng-stats.csv /etc/logstash/Data
