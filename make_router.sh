#!/bin/sh
grep _request -ir application.dats | awk '{print $2}' | sed 's/_request//' | awk '{print "| \""$1"\"  => " $1"_request"}' | column -t
