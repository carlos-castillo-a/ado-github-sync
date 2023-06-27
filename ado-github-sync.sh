#!/bin/bash

# Define script parameters
GitHubDestinationPAT="$1"
ADOSourcePAT="$2"
AzureRepoName="$3"
ADOCloneURL="$4"
GitHubCloneURL="$5"

echo ' - - - - - - - - - - - - - - - - - - - - - - - - -'
echo ' Reflect Azure DevOps repo changes to GitHub repo'
echo ' - - - - - - - - - - - - - - - - - - - - - - - - -'

# Define directories and URLs
stageDir=$(pwd)
echo "stage Dir is: $stageDir"
githubDir="$stageDir/github"
echo "github Dir: $githubDir"
destination="$githubDir/$AzureRepoName.git"
echo "destination: $destination"

# Remove existing githubDir if it exists
if [ -d "$githubDir" ]; then
  rm -rf "$githubDir"
fi

# Create githubDir
mkdir -p "$githubDir"
cd "$githubDir" || exit

# Clone Azure DevOps repository
git clone --mirror "https://$ADOSourcePAT@$ADOCloneURL"

# Add remote for GitHub repository if it doesn't exist
cd "$destination" || exit
if ! git remote | grep -q "secondary"; then
  git remote add --mirror=fetch secondary "https://$GitHubDestinationPAT@$GitHubCloneURL"
fi

# Fetch changes from Azure DevOps repository
git fetch origin

# Push changes to GitHub repository
git push secondary --all -f

echo '** Azure DevOps repo synced with GitHub repo **'

# Clean up githubDir
cd "$stageDir" || exit
rm -rf "$githubDir"

echo "Job completed"
