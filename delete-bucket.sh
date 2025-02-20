#!/bin/bash

# Check if bucket name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <bucket-name>"
  exit 1
fi

BUCKET_NAME="$1"

# List all object versions and delete markers
versions=$(aws s3api list-object-versions --bucket $BUCKET_NAME --query='Versions[].{Key:Key,VersionId:VersionId}')
delete_markers=$(aws s3api list-object-versions --bucket $BUCKET_NAME --query='DeleteMarkers[].{Key:Key,VersionId:VersionId}')

# Combine versions and delete markers
objects=$(echo $versions $delete_markers | jq -s 'add')

# Check if objects is not empty
if [ "$(echo $objects | jq 'length')" -gt 0 ]; then
  # Format objects for delete-objects command
  delete_objects=$(echo $objects | jq '{Objects: .}')
  # Delete all versions and delete markers
  aws s3api delete-objects --bucket $BUCKET_NAME --delete "$delete_objects"
fi

# Remove the bucket
aws s3 rb s3://$BUCKET_NAME --force

echo "$BUCKET_NAME removed"