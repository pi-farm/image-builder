#!/bin/bash

# Navigate to project path
#cd "$PROJECTPATH" || { echo "Error: Cannot change to project directory"; exit 1; }

# Split the ARCH variable into an array
IFS=',' read -ra ARCH_ARRAY <<< "$ARCH"

# Map architectures to Dockerfiles
declare -A ARCH_DOCKERFILES=(
    ["linux/386"]="$DF386"
    ["linux/amd64"]="$DFAMD64"
    ["linux/arm64"]="$DFARM64"
)

# Ensure delete-tag.sh exists on the same level as this script
#DELETE_TAG_SCRIPT="$(dirname "$0")/delete-tag.sh"
#if [[ ! -f "$DELETE_TAG_SCRIPT" ]]; then
#    echo "Error: delete-tag.sh script not found!"
#    exit 1
#fi

# Navigate to project path
cd "$PROJECTPATH" || { echo "Error: Cannot change to project directory"; exit 1; }

# Delete existing 'latest' tags
echo "Removing existing 'latest' tags..."
source ../../delete-tag.sh

# Build and tag images for each architecture
for ARCH in "${ARCH_ARRAY[@]}"; do
    DOCKERFILE="${ARCH_DOCKERFILES[$ARCH]}"
    TAG_ARCH="latest-${ARCH##*/}"
    VERSION_TAG="$REPO/$PROJECTNAME:$VERSION-${ARCH##*/}"

    if [[ -z "$DOCKERFILE" ]]; then
        echo "Error: No Dockerfile specified for architecture $ARCH. Skipping..."
        continue
    fi

    echo "Building image for $ARCH with Dockerfile: $DOCKERFILE..."
    docker buildx build --platform "$ARCH" -f "$DOCKERFILE" $BUILDER_CACHE_OPTION --load \
        -t "$VERSION_TAG" \
        -t "$REPO/$PROJECTNAME:$TAG_ARCH" .

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to build image for $ARCH. Aborting."
        cd ../..
        exit 1
    fi

    echo "Image built for $ARCH: $VERSION_TAG"
done

# Push the images
for ARCH in "${ARCH_ARRAY[@]}"; do
    TAG_ARCH="latest-${ARCH##*/}"
    VERSION_TAG="$REPO/$PROJECTNAME:$VERSION-${ARCH##*/}"

    echo "Pushing image for $ARCH..."
    docker push "$VERSION_TAG"
    docker push "$REPO/$PROJECTNAME:$TAG_ARCH"
done

# Create and push the multi-architecture manifest for the version tag
echo "Creating multi-architecture manifest for version $VERSION..."
docker manifest create "$REPO/$PROJECTNAME:$VERSION" \
    $(for ARCH in "${ARCH_ARRAY[@]}"; do echo "$REPO/$PROJECTNAME:$VERSION-${ARCH##*/}"; done)

docker manifest push "$REPO/$PROJECTNAME:$VERSION"

# Create and push the multi-architecture manifest for the 'latest' tag
echo "Creating multi-architecture manifest for 'latest'..."
docker manifest create "$REPO/$PROJECTNAME:latest" \
    $(for ARCH in "${ARCH_ARRAY[@]}"; do echo "$REPO/$PROJECTNAME:latest-${ARCH##*/}"; done)

docker manifest push "$REPO/$PROJECTNAME:latest"

# Navigate two levels up
cd ../..

# Increment the version number if enabled
if [[ $INCREASE == "yes" ]]; then
    sv=$(sed -n '4p' "$PROJECT_CONF")
    svn=$((sv + 1))
    sed -i "4s/.*/$svn/" "$PROJECT_CONF"
    echo "Version number increased to $svn in $PROJECT_CONF."
fi

echo "Build and push process completed successfully."
