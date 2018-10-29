#!/usr/bin/env python3
import subprocess
import time
from subprocess import *

#only import if using the socket method
#import socket

#name = (socket.gethostname())
#print(name)

# Get the elasticsearch node name included in the output of redis
proc = Popen(["curl", "-XGET", "localhost:9200/_cat/nodes?h=name"], stdout=PIPE, stderr=PIPE)
time.sleep(5)
# Split sttout and stderr to eliminate the exit code
out, err = proc.communicate()
exitcode = proc.returncode
# Convert the output of curl from bytes to ASCII
hostname = (out.decode("utf-8"))


# run and save the results of redis-cli stats
subprocess.call
with open('redis-cli-stats.txt', 'wb') as out:
    subprocess.call(['redis-cli','info'], stdout=out)

filename = "redis-cli-stats.txt"

f = open("redis-cli-stats.json", "w+")

file = open(filename, "r")
#set the value of previous line to 0
#use two variables because must use current to check if it is last line
#will print by previous line

# Prints the Leading { to start the Json record
f.write("{")
# Inserts the Hostname to the beginning of the document
f.write("\"Host\"" + ":" + "{") 
f.write( "\"name\"" + ":" + "\"" + hostname[:-1] + "\"" + "},")
previous_line = None
count = 0
#if line in file will use it, if it is eof then line will not be evaluated
for current_line in file:
    #use count to evaluate which line you are in file
    #if reading first line of object then count will increment to one and save previous to current and continue
    count+=1
    if(count == 1):
        previous_line = current_line
    elif(count == 2):
        f.write("\"" + previous_line[2:-1] + "\"" + ":" + "{")
        previous_line = current_line
    #if current line > 1 then that means there is something to evaluate on line
    #print data 
    elif(len(current_line) > 1):
        user, text = previous_line.split(":")
        f.write("\"" + user + "\"" + ":" + "\"" + text[:-1] + "\"" + ",")
        previous_line = current_line 
    else:
        user, text = previous_line.split(":")
        f.write("\"" + user + "\"" + ":" + "\"" + text[:-1] + "\"")
        f.write("},")
        previous_line = current_line
        count = 0

if(count == 2):
    #if count = 2 that means that there is only one line of data for that object
    #it will print that line
    #if the line is empty it will print empty line
    #previous line always moved to current line

    user, text = previous_line.split(":")
    f.write("\"" + user + "\"" + ":" + "\"" + text[:-1] + "\"")
#    print(previous_line, end='')
    f.write("}}")

    f.close()

# curl the JSON logstash
# curl -XPOST 'localhost:9200/test2/1' -H 'Content-Type: application/json' -d @redis-cli-stats.json
subprocess.call(["curl", "-XPOST", "-H", "Content-Type: application/json", "localhost:6000", "-d", "@redis-cli-stats.json"], shell=False)

#file cleanup

subprocess.call(['rm','redis-cli-stats.json'])
subprocess.call(['rm','redis-cli-stats.txt'])


