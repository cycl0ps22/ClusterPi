#!/bin/bash

# GitHub repository URL
REPO_URL=https://github.com/cycl0ps22/ClusterPi.git
# Directory to clone the repository
CLONE_DIR=/tmp/ClusterPi

# Function to deploy changed YAML files
deploy_changes() {
    local changed_files=("$@")
    if [ ${#changed_files[@]} -eq 0 ]; then
        echo "No changes detected in YAML files."
    else
        echo "Deploying changed YAML files:"
        for file in "${changed_files[@]}"; do
            echo "- $file"
            kubectl apply -f "$file"
        done
    fi
}

# Function to detect changes in YAML files
detect_changes() {
    local changed_yaml_files=()
    while IFS= read -r file; do
        changed_yaml_files+=("$file")
    done < <(git -C "$CLONE_DIR" diff --name-only HEAD^ HEAD *.yaml)
    deploy_changes "${changed_yaml_files[@]}"
}

# Main script execution starts here
echo "Cloning the GitHub repository..."
git clone "$REPO_URL" "$CLONE_DIR" || { echo "Error: Unable to clone the repository."; exit 1; }

echo "Checking for changes in YAML files..."
detect_changes || echo "No changes detected in YAML files."

echo "Removing the cloned repository directory..."
rm -rf "$CLONE_DIR"
