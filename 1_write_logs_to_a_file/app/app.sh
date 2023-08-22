#!/bin/sh
while true
do
  echo "Writing log to a file"
  echo '{"info":"an example log message"}' >> /app/app.log
  sleep 5
done
