#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <file> <searchstring> <replacementstring>"
  exit 1
fi

file="$1"
searchstring="$2"
replacement="$3"

# Debug: Print the file name and search/replacement strings
echo "File: $file"
echo "Search string: $searchstring"
echo "Replacement string: $replacement"

# Read the entire file as a single line
line=$(cat "$file")

# Debug: Print the entire line
# echo "Processing line: $line"

# Use grep to find URLs that include the search string
urls=$(echo "$line" | grep -o "http[s]\?://[^ )}]*")

# Debug: Print found URLs
echo "Found URLs: $urls"

# Replace the search string with the replacement string in the URLs
for url in $urls; do
  # Debug: Print the current URL being processed
  echo "Processing URL: $url"
  
  if [[ "$url" == *"$searchstring"* ]]; then
    new_url=$(echo "$url" | sed "s|$searchstring|$replacement|g")
    
    # Check if the URL is wrapped with parentheses or curly braces
    if [[ "$line" == *"($url)"* ]]; then
      new_url="($new_url)"
    elif [[ "$line" == *"{$url}"* ]]; then
      new_url="{$new_url}"
    fi
    
    # Debug: Print original and new URLs
    echo "Original URL: $url"
    echo "New URL: $new_url"
    
    echo "$new_url"
  fi
done