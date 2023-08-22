#!/bin/sh
while true
do
	echo "Writing log to a file"
  echo '{"app":"file-myapp"}' >> /app/example.log
	sleep 5
done
