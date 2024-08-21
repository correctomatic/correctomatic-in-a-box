#!/bin/bash

# Usage: ./remove_old_containers.sh <N>
# Where <N> is the number of minutes

# Check if a valid argument (number of minutes) is provided
if [ -z "$1" ]; then
  echo "Please provide the number of minutes as an argument."
  exit 1
fi

# Get the number of minutes
MAX_MINUTES=$1

# Get the current time in seconds since epoch
current_time=$(date +%s)

# List all containers with names starting with "correction-"
containers=$(docker ps -a --filter "name=correction-" --format '{{.Names}}')

for container in $containers; do
    # Get the creation time of the container in ISO 8601 format
    creation_time=$(docker inspect --format '{{.Created}}' "$container")

    # Convert creation time to seconds since epoch
    container_created_time=$(date -d "$creation_time" +%s)

    # Calculate the difference in minutes
    minutes_since_creation=$(( (current_time - container_created_time) / 60 ))

    # If the container is older than AGE_LIMIT minutes, remove it
    if [ "$minutes_since_creation" -gt "$MAX_MINUTES" ]; then
        echo "Container '$container' is $minutes_since_creation minutes old and will be removed."
        docker rm -f "$container" > /dev/null
    fi
done
