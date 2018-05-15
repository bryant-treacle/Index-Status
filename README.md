
# Index Stats for Security Onion 
 
# Prerequisites 
Run on Security Onion 14.04.5.12 and higher running Elastic Stack.  The dashboards are optimized for a Master Node with forward only Sensors but will work with a Master Node and Heavy Sensors. 
# Installing 
Step 1. Download the repository and extract the contents in the home directory of the Master Node.  If running Heavy sensors, the files must in the home directly of those sensors as well. 
 
Navigate to the Index-Status-master directory and change the file permissions for the following files to be executables.   
* Index_status_install.sh   
* Index_status.sh   
* Syslog_ng_stats.sh   
example: sudo chmod 777 Index_status_install.sh 
 
Step 2. Execute the Index_status_install.sh script and answer the questions to make the necessary change to the /etc/nsm/securityonion.conf file, add a cron job to gather index stats daily, curl the field mapping templates to elasticsearch, and to add the appropriate logstash pipeline configuration files.  
 
Step 3. After the scripts executes Logstash will need to fully initialize before the initial data can be ingested. Depending on the size of your Java Heap this may take a while.  Logstash traditionally consumes a large amount of CPU's so you can monitor HTOP and wait for the CPU utilization to spike.  You can also use docker stats to ensure Logstash started correctly.  If the logstash container fails to initialize, check the logs to identify any issues.  < /var/log/logstash/logstash.log >  
 
Below are the files that were moved to the /etc/logstash/conf.d/ folder:   
* 0050_input_index_status.conf   
* 6050_index_status.conf   
* 9050_output_index_status.conf   
Note: These files can be deleted if logstash fails to initialize properly.   
 
Step 4.  Once Logstash is fully initialized execute the index_stasus.sh and syslog_ng_stats.sh scripts.   
Note: If logstash is not fully initialized you will receive errors while the index_status.sh script attempts to curl logstash.   
 
Step 5. After the scripts have completed you will need to create the index pattern for the data ingested.  To do this follow these steps: 
* Log into Kibana and select Management from the Left hand Pane and select the Index Pattern hyperlink. 
* Select the create index pattern Hyperlink in the Top left corner of the screen.   
* Search for and select the elasticsearch-index-status indices.   
* Note: If installing this in a distributed Heavy Sensor deployment you will need to add *: before the index name to enable cross cluster search. Example *:elasticsearch-index-status   
* Select next then from the dropdown select @timestamp then create index pattern. 
* At this point you can change the index_memory_size, store_size, and store_size_per_shard fields to Bytes to make them human readable. You can do this by selecting the edit button to the right of the field, selecting bytes from the format dropdown, and the updating the field.   
 
Step 6.  Load visualizations and dashboard in Kibana. 
Note: This only needs to be done on the Master Server 
* Step 1: Log into Kibana and select Management from the left pane 
* Step 2: Select the Saved Objects Hyperlink at the Top of the Page 
* Step 3: Select the Import button and navigate to Index-Status-Master/kibana_dashboards directly 
* Step 4: Import all 3 JSON files. 
Note:  For the index_status_search.json and the index_status_visualization.json files you will be prompted to select the appropriate index.  Select the elasticsearch-index-status index. 
 
At this point you can navigate to the new dashboard by selecting Dashboards on the left pane of Kibana then searching for Index Status.  If you want to be able to pivot to this dashboard you can edit the navigation visualization and add an entry for Index Status.  You will need to copy the uri information from the index status dashboard beginning at /app and ending before the ?.  If you are unfamiliar with markdown language you will need to put 2 spaces at the end of the previous entry to have your link show up on the next line.  
 
Please feel free to leave suggestions for improvements. 
 
# Author 
Bryant Treacle 
 
# License 
This project is licensed under the MIT License - see the LICENSE.md file for details 
  
