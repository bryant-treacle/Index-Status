#!/bin/bash
#author Bryant Treacle
#date 11 May 18
#purpose: This script will query elasticsearch for index status and save
#the content as a csv.  It will then be ingested into logstash and displayed in
#kibana

#clear
#make a folder to store the results of the curl
mkdir -p /etc/logstash/Data
rm -rf /etc/logstash/Data/*.csv
curl -X DELETE "localhost:9200/elasticsearch-index-status*"
sleep 30s
#query for Elasticsearch and Logstash for Node status.  Running this multiples times to get an average of the 
# JAVA heap percentage to get a more accurate indication.
for i in {1..4}; do
	curl -XGET 'localhost:9200/_cat/nodes?' | awk '{print $2","$3}' >> /etc/logstash/Data/Elasticsearch_Node_Status.csv
	curl -XGET 'localhost:9600/_node/stats/jvm?' | jq '.jvm.mem.heap_used_percent'  >> /etc/logstash/Data/Logstash_Node_Status.csv
	sleep 5;
done
sleep 10s
#query Elasticstack for Index status and write to a file
curl -XGET 'localhost:9200/_cat/indices?&pretty' | awk '{print $1","$2","$3","$4","$5","$6","$7","$8","$9}' > /etc/logstash/Data/Index_status.csv
sleep 10s
#query Elasticsearch for Index memory utilization
curl -XGET 'localhost:9200/_cat/indices?&h=i,tm&s=tm:desc&pretty' | awk '{print $1","$2}' > /etc/logstash/Data/Index_memory.csv
sleep 10s
#query logstash to get pipeline events
curl -XGET 'localhost:9600/_node/stats/events' | jq -r '[.events[]] |@csv' > /etc/logstash/Data/Logstash_Pipeline_Events.csv
