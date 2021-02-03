#!/bin/bash
kill $(lsof -t -i:10980)
#python -m SimpleHTTPServer 10980
http-server -p 10980
