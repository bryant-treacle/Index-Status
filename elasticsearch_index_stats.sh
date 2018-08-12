#!/bin/bash

# Steve Willson
# Based off Bryant Treacle's Index-Status
# 8/4/18

# This script will query elasticsearch (port 9200) and logstash (port 9600)
# for statistics and send them through a logstash pipeline for ingestion into 
# elasticsearch 
# the logstash input plugin http is used and listens on port 9999 
# this is configured in the logstash '.conf' file 0050 (
# Note: Run this script daily to reduce the number of unique records.  Will make visualizing the Data easier!!!


### ELASTICSEARCH INDEX STATUS

# Get information from the indices in elasticsearch
curl -XGET 'localhost:9200/_cat/indices?h=health,status,index,uuid,pri,rep,docs.count,docs.deleted,store.size,memory.total&format=json&bytes=b' | curl -XPUT -H "content-type: application/json" 'http://localhost:6000/' -d @-
