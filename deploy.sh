#!/bin/bash

# Check if the commit contains changes to any YAML file
changed_yaml_files=$(git diff --name-only HEAD^ HEAD | grep "\.yaml$")
if [ -n "$changed_yaml_files" ]; then
    echo "Changes detected in YAML file(s). Deploying to Kubernetes..."

    # Apply all YAML files
    for file in $changed_yaml_files; do
        DEPLOYMENT_NAME=$(basename "$file" | cut -d. -f1)
        kubectl apply -f "$file"
        # Check deployment status
        kubectl rollout status deployment/$DEPLOYMENT_NAME
        if [ $? -eq 0 ]; then
            echo "Deployment of $DEPLOYMENT_NAME successful!"
        else
            echo "Deployment of $DEPLOYMENT_NAME failed!"
            exit 1
        fi
    done
else
    echo "No changes detected in YAML file. Skipping deployment."
fi
