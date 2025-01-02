#!/bin/bash
set -e

# Check if required arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <VAULT_NAME> <GITHUB_HEAD_REF> <COMMIT_ID>"
    exit 1
fi

# Define the Key Vault and secret names
KEY_VAULT_NAME=$1
GITHUB_HEAD_REF=$2
NEW_COMMIT_ID=$3

VERSION_SECRET_NAME="NX---PUBLIC---FRONTEND---VERSION"
HEAD_REF_SECRET_NAME="NX---PUBLIC---FRONTEND---HEAD---REF"
COMMIT_ID_SECRET_NAME="NX---PUBLIC---FRONTEND---COMMIT---ID"


# Fetch the current version from the Key Vault
current_version=$(az keyvault secret show --name "$VERSION_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
old_commit_id=$(az keyvault secret show --name "$COMMIT_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
current_github_head_ref=$(az keyvault secret show --name "$HEAD_REF_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)

echo "Current version: $current_version"
echo "current_github_head_ref (from Key Vault): $current_github_head_ref"
echo "GITHUB_HEAD_REF: $GITHUB_HEAD_REF"
echo "Old Commit ID: $old_commit_id"
echo "New commit ID: $NEW_COMMIT_ID"

# Check if the commit ID in the Key Vault matches the provided commit ID
if [[ "$old_commit_id" == "$NEW_COMMIT_ID" ]]; then
    echo "Commit IDs match, version will not be updated."
    exit 0
fi

# Check if the GITHUB_HEAD_REF is one of the allowed branches: 'dev', 'staging', or 'main'
if [[ "$current_github_head_ref" == "$GITHUB_HEAD_REF" ]]; then
    echo "Base ref is valid for version increment."

    # Split the version into components (major, minor, patch)
    IFS='.' read -ra VERSION_PARTS <<< "$current_version"
    major=${VERSION_PARTS[0]}
    minor=${VERSION_PARTS[1]}
    patch=${VERSION_PARTS[2]}

    # Increment patch version
    new_patch=$((patch + 1))

    # Construct the new version
    new_version="$major.$minor.$new_patch"
    echo "New version: $new_version"

    # Update the version in the Key Vault
    az keyvault secret set --name "$VERSION_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --value "$new_version"

else
    echo "Base ref is not valid for version increment. No versioning changes will be made."
    exit 0
fi

# Update commit ID in the Key Vault
az keyvault secret set --name "$COMMIT_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --value "$NEW_COMMIT_ID"