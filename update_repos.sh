#!/bin/bash

# Define the list of repositories you want to update
repos=(
    "/mnt/Uyuni/Projects/Notes/Obsidian-Vault master"
    # Add more repositories as needed
)

# Function to update a single repository
update_repo() {
    local repo_info=($1)  # Split the input string into an array
    local repo_path="${repo_info[0]}"
    local branch_name="${repo_info[1]}"

    if [ -d "$repo_path" ]; then
        echo "Processing repository at $repo_path on branch $branch_name"
        cd "$repo_path" || exit

        # Check if we're on the correct branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        change_branch=false
        if [ "$current_branch" != "$branch_name" ]; then
            echo "Switching to branch $branch_name"
            git checkout "$branch_name"
            change_branch=true
        fi

        # Check for changes
        if [ -n "$(git status --porcelain)" ]; then
            echo "Changes detected in $repo_path"

            # Add all changes
            git add .

            # Commit changes with a default message
            git commit -m "Automated commit: $(date '+%Y-%m-%d %H:%M:%S')"

            echo "Changes committed."
        else
            echo "No changes to commit in $repo_path."
        fi

        # Pull the latest changes from the remote
        git pull origin "$branch_name"

        # Push any local changes to the remote
        git push origin "$branch_name"

        echo "Repository at $repo_path updated successfully."

        if [ change_branch == true ]; then
            echo "Switching back to branch $branch_name"
            git checkout "$current_branch"
        fi
    else
        echo "Directory $repo_path does not exist. Skipping."
    fi
}

# Iterate over each repository and update it
for repo in "${repos[@]}"; do
    update_repo "$repo"
done

echo "All repositories have been updated."
