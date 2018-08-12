#!/bin/bash

# Steve Willson
# Based off Bryant Treacle's Index-Status
# 8/4/18

# This script will query elasticsearch (port 9200) and logstash (port 9600)
# for statistics and send them through a logstash pipeline for ingestion into  
# the logstash input plugin http is used and listens on port 6000
# this is configured in the logstash '.conf' file 0050 

while true
do

### ELASTICSEARCH NODE STATUS
# Get the node name and the used heap and ram ratio
curl -XGET 'localhost:9200/_cat/nodes?h=name,heap.percent,ram.percent,search.fetch_time,search.query_time&format=json&time=ms' | curl -XPUT -H "content-type: application/json" 'http://localhost:6000/' -d @-

# Get Elasticsearch Cluster Health
curl -XGET 'localhost:9200/_cat/health?h=cluster,status,node.total,node.data,max_task_wait_time,shards,pri,relo,init,unassign,pending_tasks,active_shards_percent&format=json' | tr '\045' '0'  | tr - 0 | curl -XPUT -H "content-type: application/json" 'http://localhost:6000/' -d @-

### LOGSTASH STATUS

# Get the java virtual machine heap memory usage ratio and name 
curl -XGET 'localhost:9600/_node/stats/jvm' | jq -r '. | {name: .name, logstash_heap_percent: .jvm.mem.heap_used_percent, gc_young_count: .jvm.gc.collectors.young.collection_count, gc_old_count: .jvm.gc.collectors.old.collection_count}' | curl -XPUT -H "content-type: application/json" 'http://localhost:6000/' -d @-

## LOGSTASH PIPELINE STATUS

# Can I ingest the json document right into elasticsearch or logstash?
curl -XGET 'localhost:9600/_node/stats/events' | jq -r '.| {name: .name, events_in: .events.in, events_filtered: .events.filtered, events_out: .events.out, events_duration: .events.duration_in_millis, events_queue_push_duration: .events.queue_push_duration_in_millis}' | curl -XPUT -H "content-type: application/json" 'http://localhost:6000/' -d @-
sleep 10
done
