#!/bin/bash

# Define the paths to the patch scripts
SCRIPTS_DIR=~/bin/patch-utils
SCRIPTS=("apply-file-patch.sh" "revert-file-patch.sh" "validate-patch.sh" "list-patches.sh" "backup-patch.sh" "undo-file-patch.sh" "create-dir-patch.sh" "apply-dir-patch.sh")

# Function to display usage message
usage() {
    echo "Usage: $0 <script_name> <arg1> <arg2> ..."
    exit 1
}

# Function to set up the test environment
setup_test_env() {
    # Create test directories
    mkdir -p ~/tests/test-env/original-dir
    mkdir -p ~/tests/test-env/patch-dir

    # Create sample files in the original directory
    echo "This is a test file." > ~/tests/test-env/original-dir/test-file.txt

    # Create a patch file
    cat <<EOL > ~/tests/test-env/patch-dir/test-file.patch
--- test-file.txt
+++ test-file.txt
@@ -1 +1 @@
-This is a test file.
+This is a patched test file.
EOL
}

# Function to tear down the test environment
teardown_test_env() {
    rm -rf ~/tests/test-env
}

# Function to test a script
test_script() {
    local script=$1
    echo "Testing $script..."

    # Define test cases
    case $script in
        "apply-file-patch.sh")
            # Add test cases for apply-file-patch.sh
            $SCRIPTS_DIR/$script ~/tests/test-env/original-dir/test-file.txt ~/tests/test-env/patch-dir/test-file.patch
            ;;
        "revert-file-patch.sh")
            # Add test cases for revert-file-patch.sh
            $SCRIPTS_DIR/$script ~/tests/test-env/original-dir/test-file.txt ~/tests/test-env/patch-dir/test-file.patch
            ;;
        "validate-patch.sh")
            # Add test cases for validate-patch.sh
            $SCRIPTS_DIR/$script ~/tests/test-env/patch-dir/test-file.patch
            ;;
        "list-patches.sh")
            # Add test cases for list-patches.sh
            $SCRIPTS_DIR/$script ~/tests/test-env/patch-dir
            ;;
        "backup-patch.sh")
            # Add test cases for backup-patch.sh
            $SCRIPTS_DIR/$script ~/tests/test-env/original-dir/test-file.txt
            ;;
        "undo-file-patch.sh")
            # Add test cases for undo-file-patch.sh
            $SCRIPTS_DIR/$script ~/tests/test-env/original-dir ~/tests/test-env/patch-dir/test-file.patch
            ;;
        "create-dir-patch.sh")
            # Add test cases for create-dir-patch.sh
            $SCRIPTS_DIR/$script ~/tests/test-env/original-dir ~/tests/test-env/patch-dir/patch-dir-file
            ;;
        "apply-dir-patch.sh")
            # Add test cases for apply-dir-patch.sh
            $SCRIPTS_DIR/$script ~/tests/test-env/patch-dir/patch-dir-file
            ;;
        *)
            echo "No test cases defined for $script"
            ;;
    esac

    # Check the result of the script execution
    if [ $? -eq 0 ]; then
        echo "$script passed"
    else
        echo "$script failed"
    fi
}

# Set up the test environment
setup_test_env

# Test all scripts
for script in "${SCRIPTS[@]}"; do
    test_script $script
done

# Tear down the test environment
teardown_test_env