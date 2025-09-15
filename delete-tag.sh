#!/bin/bash

# Variables passed from the calling script
# REPO: The registry URL
# PROJECTNAME: Project name (used as part of the repo)

if [ -z "$REPO" ] || [ -z "$PROJECTNAME" ]; then
    echo "Error: Required variables (REPO, PROJECTNAME) are not set."
    exit 1
fi

# List of tags to delete
TAGS_TO_DELETE=("latest" "latest-386" "latest-amd64" "latest-arm64")

# Loop through each tag and delete it
for TAG in "${TAGS_TO_DELETE[@]}"; do
    echo "Deleting tag '$TAG' from '$REPO/$PROJECTNAME'..."
    
    # Special handling for 'latest' (Multi-Arch-Manifest)
    if [[ "$TAG" == "latest" ]]; then
        DIGEST=$(docker manifest inspect "$REPO/$PROJECTNAME:$TAG" 2>/dev/null | jq -r '.digest // empty')
    else
        DIGEST=$(docker manifest inspect "$REPO/$PROJECTNAME:$TAG" 2>/dev/null | jq -r '.Descriptor.digest // empty')
    fi

    if [ -z "$DIGEST" ]; then
        echo "Warning: Tag '$TAG' does not exist or cannot retrieve digest. Skipping."
        continue
    fi

    echo "Digest for $TAG: $DIGEST"

    # Construct DELETE URL
    DELETE_URL="https://$REPO/v2/$PROJECTNAME/manifests/$DIGEST"

    # Perform the deletion
    echo "Deleting manifest digest '$DIGEST' for tag '$TAG'..."
    if curl -s -X DELETE "$DELETE_URL"; then
        echo "Successfully deleted tag '$TAG' from '$REPO/$PROJECTNAME'."
    else
        echo "Error: Failed to delete the tag '$TAG'. Please check the registry or credentials."
    fi
done

echo "Tag deletion process completed."
