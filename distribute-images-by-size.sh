#!/bin/bash

# Script to distribute image files from a directory into N subdirectories
# aiming for approximately equal total size in each subdirectory.

# 1. Argument parsing and validation
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <img_dir> <N> <base_name>"
    echo "  img_dir:   Directory containing image files."
    echo "  N:         Number of subdirectories to create."
    echo "  base_name: Base name for subdirectories (script processes if 'today')."
    exit 1
fi

img_dir="${1%/}" # Remove trailing slash if any
N="$2"
base_name="$3"

if [ ! -d "$img_dir" ]; then
    echo "Error: Image directory '$img_dir' not found."
    exit 1
fi

if ! [[ "$N" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: N must be a positive integer (e.g., 1, 2, 3...)."
    exit 1
fi

# 2. Check base_name condition
if [ "$base_name" != "today" ]; then
    echo "Info: base_name is '$base_name'. This script currently only processes the special case where base_name is 'today'."
    exit 0
fi

echo "Processing image directory: $img_dir"
echo "Number of subdirectories to create: $N"
echo "Base name for subdirectories: $base_name"

# 3. Create target subdirectories
declare -a target_dirs
for i in $(seq 1 "$N"); do
    dir_name="${img_dir}/${base_name}_${i}"
    target_dirs+=("$dir_name")
    if ! mkdir -p "$dir_name"; then
        echo "Error: Could not create directory '$dir_name'"
        exit 1
    fi
    echo "Created directory: $dir_name"
done

# 4. List image files and their sizes
declare -a image_files_paths
declare -a image_files_sizes

echo "Scanning for image files in '$img_dir'..."
# Use find to get files, -maxdepth 1 for non-recursive, -print0 for safe filenames
# Common image extensions, case-insensitive
while IFS= read -r -d $'\0' file; do
    # Get file size - macOS compatible
    size=$(stat -f %z "$file") 
    image_files_paths+=("$file")
    image_files_sizes+=("$size")
done < <(find "$img_dir" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \
    -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.tif" -o -iname "*.webp" \
    -o -iname "*.heic" -o -iname "*.heif" \) -print0)

if [ ${#image_files_paths[@]} -eq 0 ]; then
    echo "No image files found in '$img_dir' with specified extensions."
    # Optional: Clean up created directories if no files found
    # for dir_to_remove in "${target_dirs[@]}"; do
    #     rmdir "$dir_to_remove" 2>/dev/null || echo "Directory $dir_to_remove not empty or error removing."
    # done
    exit 0
fi

echo "Found ${#image_files_paths[@]} image files."

# 5. Sort image files by size in descending order
# Create a temporary list of "size filepath" for sorting
tmp_file_list_for_sorting=$(mktemp)
for i in "${!image_files_paths[@]}"; do
    echo "${image_files_sizes[i]} ${image_files_paths[i]}" >> "$tmp_file_list_for_sorting"
done

declare -a sorted_image_files_paths
declare -a sorted_image_files_sizes
# Sort by the first field (size), numerically, in reverse (descending) order
while IFS= read -r size path_and_maybe_more; do # path_and_maybe_more to handle spaces in path
    sorted_image_files_sizes+=("$size")
    sorted_image_files_paths+=("$path_and_maybe_more") # Store the full path correctly
done < <(sort -k1,1nr "$tmp_file_list_for_sorting")
rm "$tmp_file_list_for_sorting"


# 6. Distribute files
# Initialize array to keep track of current total size in each target subdirectory
declare -a subdir_accumulated_sizes
for i in $(seq 0 $((N-1))); do
    subdir_accumulated_sizes[$i]=0
done

echo "Distributing files..."
for i in "${!sorted_image_files_paths[@]}"; do
    file_to_move="${sorted_image_files_paths[i]}"
    file_size="${sorted_image_files_sizes[i]}"

    # Find the target subdirectory with the current minimum accumulated size
    min_accumulated_size_idx=0
    current_min_total_size=${subdir_accumulated_sizes[0]}

    # Ensure N > 1 for this loop to avoid issues with seq when N=1
    if [ "$N" -gt 1 ]; then
      for j in $(seq 1 $((N-1))); do
          if [ "${subdir_accumulated_sizes[j]}" -lt "$current_min_total_size" ]; then
              current_min_total_size=${subdir_accumulated_sizes[j]}
              min_accumulated_size_idx=$j
          fi
      done
    fi

    target_subdir_for_file="${target_dirs[$min_accumulated_size_idx]}"
    
    echo "Moving '$(basename "$file_to_move")' (size: $file_size bytes) to '$target_subdir_for_file'"
    if mv "$file_to_move" "$target_subdir_for_file/"; then
        # Update the accumulated size of the target subdirectory
        new_size=$(( subdir_accumulated_sizes[min_accumulated_size_idx] + file_size ))
        subdir_accumulated_sizes[$min_accumulated_size_idx]=$new_size
    else
        echo "Error: Failed to move '$file_to_move' to '$target_subdir_for_file'. Skipping this file."
        # Optionally, add more robust error handling here
    fi
done

echo ""
echo "File distribution complete."
echo "Final approximate total sizes in subdirectories:"
for i in $(seq 0 $((N-1))); do
    echo "  ${target_dirs[i]}: ${subdir_accumulated_sizes[i]} bytes"
done

exit 0 