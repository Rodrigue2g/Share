#! bin/bash
# Git remote is set to use HTTPS, but as GitHub removed password authentication over HTTPS. 
# we must switch the Git remote to use SSH instead of HTTPS. 
# Make sure you have an SSH key already set up!

# Check the current remote
$ git remote -v
# This should output something like that:
# origin  https://github.com/<your_git_username>/<your_repo_name>.git (fetch)
# origin  https://github.com/<your_git_username>/<your_repo_name>.git (push)

# Which we should change to git@github.com (instead of https://github.com/) 
# In order to use SSH instead of password auth.
$ git remote set-url origin git@github.com:<your_git_username>/<your_repo_name>.git

# Make sure the changes took effect
$ git remote -v

# You can now push again
$ git push -f origin main
