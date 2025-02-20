#!/bin/bash

# Create test directories
mkdir -p ~/test-env/original-dir
mkdir -p ~/test-env/patch-dir

# Create sample files in the original directory
echo "This is a test file." > ~/test-env/original-dir/test-file.txt

# Create a patch file
cat <<EOL > ~/test-env/patch-dir/test-file.patch
--- test-file.txt
+++ test-file.txt
@@ -1 +1 @@
-This is a test file.
+This is a patched test file.
EOL