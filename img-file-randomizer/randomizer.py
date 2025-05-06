import os
import random
import string
import sys

def generate_random_name(length=8):
  """Generates a random string of lowercase letters and digits."""
  characters = string.ascii_lowercase + string.digits
  return ''.join(random.choice(characters) for _ in range(length))

def rename_image_files(directory="."):
  """Renames image files in the specified directory with random names."""
  target_extensions = ('.jpg', '.jpeg', '.png', '.gif')
  renamed_count = 0
  skipped_count = 0
  
  print(f"Scanning directory: {os.path.abspath(directory)}")
  
  try:
    all_files = os.listdir(directory)
  except FileNotFoundError:
    print(f"Error: Directory not found: {directory}")
    return
  except PermissionError:
     print(f"Error: Permission denied to read directory: {directory}")
     return

  existing_names = set(all_files) # Keep track of existing names to avoid collisions

  for filename in all_files:
    # Split filename and extension, handle cases like '.jpeg'
    name_part, ext_part = os.path.splitext(filename)
    
    # Check if the extension is one we're interested in (case-insensitive)
    if ext_part.lower() in target_extensions:
      # Generate a new name until we find one that doesn't exist
      new_name_part = generate_random_name()
      new_filename = new_name_part + ext_part
      while new_filename in existing_names:
          print(f"Collision detected for {new_filename}, regenerating...")
          new_name_part = generate_random_name()
          new_filename = new_name_part + ext_part
          
      # Get full paths
      old_path = os.path.join(directory, filename)
      new_path = os.path.join(directory, new_filename)
      
      # Rename the file
      try:
        os.rename(old_path, new_path)
        print(f"Renamed: '{filename}' -> '{new_filename}'")
        existing_names.remove(filename) # Remove old name from set
        existing_names.add(new_filename) # Add new name to set
        renamed_count += 1
      except OSError as e:
        print(f"Error renaming '{filename}': {e}")
        skipped_count += 1
    # else:
    #    print(f"Skipping non-target file: {filename}") # Optional: log skipped files

  print("\n----- Rename Summary -----")
  print(f"Files renamed: {renamed_count}")
  print(f"Files skipped (errors): {skipped_count}")
  print("------------------------")

if __name__ == "__main__":
  # Default to current directory, but allow specifying one as argument
  target_dir = "."
  if len(sys.argv) > 1:
      target_dir = sys.argv[1]
      if not os.path.isdir(target_dir):
          print(f"Error: Provided path '{target_dir}' is not a valid directory.")
          sys.exit(1)
          
  rename_image_files(target_dir)
