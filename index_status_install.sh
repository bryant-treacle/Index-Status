#!/bin/bash
#author Bryant Treacle
#date 11 May 2018
#purpose: This script will install the components needed to gain insight into basic management of Elasticseach Indices, Logstash Pipelines, and Syslog-ng traffic from Sensors


#clear
echo "This Script will automate the steps needed to configure Security Onion to ingest index statistics"
echo "Do you want to continue? (Y/N)" 
read userselect

if [ ${userselect,,} = "y" ] ; then
	echo "Copy logstash config files from ~/index_status/logstash_configs/ to /etc/logstash/conf.d/"
	    chmod 777 index_status.sh
	    chmod -R 644 logstash_config/index_status/*
	    cp logstash_config/index_status/*.conf /etc/logstash/conf.d/
# send index field mapping template to elasticsearch	
	echo "Sending index status mapping template to Elasticsearch"
	echo ""
            curl -XPUT 'localhost:9200/_template/elasticsearch-index' -H 'Content-Type: application/json' -d @logstash_config/index_status/elasticsearch-index-template.json
        echo ""
        #Add a cron job to run the index_status script
	    username=$(pwd)
	echo "Is '$username/index_status.sh' the location of the index_status.sh script? (Y/N)"
            read  scriptlocation
                if [ ${scriptlocation,,} = "y" ] ; then
                    echo "Adding a cron job to run index_status.sh daily  and syslog_ng_stats.sh hourly."
                    chmod 777 index_status.sh && chmod 777 syslog_ng_stats.sh
		    chown root:root index_status.sh && chown root:root syslog_ng_stats.sh
		    cp index_status.sh /etc/cron.daily && cp syslog_ng_stats.sh /etc/cron.hourly
		
                elif [ ${scriptlocation,,} = "n" ] ; then
                    echo "Enter the location (including the file name) of the script. example /home/user/"
                    read scriptuserlocation
                    echo "Is '$scriptuserlocation' the correct location of the script? (Y/N)"
                    read scriptlocationcheck
                    if [ ${scriptlocationcheck,,} = "y" ] ; then
			echo "Adding a cron job to run index_status.sh daily  and syslog_ng_stats.sh hourly but need the location of the scripts"
                        chmod 777 index_status.sh && chmod 777 syslog_ng_stats.sh
                        chown root:root index_status.sh && chown root:root syslog_ng_stats.sh
                        cp index_status.sh /etc/cron.daily && cp syslog_ng_stats.sh /etc/cron.hourly
		    elif [ ${scriptlocationcheck,,} = "n" ] ; then
                	echo "Enter the location (including the file name) of the script. example /home/user/index_status.sh"
                        read scriptuserlocation
                	echo "Is '$scriptuserlocation' the correct location of the script? (Y/N)"
                	read scriptlocationcheck
                    		if [ ${scriptlocationcheck,,} = "n" ] ; then
				    echo "Adding a cron job to run index_status.sh daily  and syslog_ng_stats.sh hourly but need the location of the scripts"
                    		    chmod 777 index_status.sh && chmod 777 syslog_ng_stats.sh
                    		    chown root:root index_status.sh && chown root:root syslog_ng_stats.sh
                    		    cp index_status.sh /etc/cron.daily && cp syslog_ng_stats.sh /etc/cron.hourly
 		    		else  
                       		     echo "exiting"
                    		fi
             	    fi
		fi
 	echo "Need to mount a new volume to the logstash docker container.  This is done by utilizing the LOGSTAH_OPTIONS in the /etc/nsm/securityonion.conf"
        	currentlogstashoptions="$(sudo cat /etc/nsm/securityonion.conf | grep LOGSTASH_OPTIONS)"
	echo "Here are your current LOGSTASH_OPTIONS:   $currentlogstashoptions"
	echo "If you already have logstash options configured  press 1, if not press any key to continue"
	read logstashchoice
	if [ $logstashchoice = "1" ] ; then
	    echo "Add the following to your existing options to mount a new volume: --volume /etc/logstash/Data:/etc/logstash/Data:ro"
	    echo "Enter All logstash options as they should appear in the securityonion.conf file"
	    read logstashoptions
		echo "Adding Logstash Options now"
	    sudo sed -i 's|LOGSTASH_OPTIONS.*|'"$logstashoptions"'|g' /etc/nsm/securityonion.conf
	else
	    echo "Adding Logstash Options now"
	    sudo sed -i 's|LOGSTASH_OPTIONS=""|LOGSTASH_OPTIONS="--volume /etc/logstash/Data:/etc/logstash/Data:ro"|g' /etc/nsm/securityonion.conf
	# Allow logstash container access to /etc/logstash/Data directory
	fi
	echo "Restarting Logstash Docker"
	so-logstash-restart
	echo "Once logstash fully initializes run the index_status.sh script to ingest the initial data."
	echo ""
	sleep 5
	echo "This will be needed to build the index pattern in Kibana."
	echo ""
	sleep 5
	echo "A Pre-configured Dashboard with visualizations and searches are located in script/kibana_dashboards folder." 
	echo ""
	sleep 5
	echo "Import them using Kibana's Management -> Saved Object -> import feature"
        echo ""
	sleep 5
	echo "You will also want to edit the navigate visualization and add the index status dashboard as a hyper-link."
fi
