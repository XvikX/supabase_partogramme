#!/bin/bash
anonKey="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
# Initialize our own variables:
fctname=""

# Parse the flags with getopts
while getopts ":n:" opt; do
  case ${opt} in
    n)
      fctname=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

# Example: Use command line arguments
echo "The first argument is: $1"
echo "The second argument is: $2"

curl --request POST "http://localhost:54321/functions/v1/${fctname}" \
  --header "Authorization: Bearer ${anonKey}" \
  --header 'Content-Type: application/json' \
  --data '{ "name":"Functions" }'
# Add more code as needed

