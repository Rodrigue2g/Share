#! bin/bash
# Clean Git History (remove all the previous commits whils keeping the current code)
# If your git history is a mess or you did some undesired commits, this is a simple and straightforward way to be off to a fresh start

$ git checkout --orphan new-branch

$ git add -A

$ git commit -m "Initial commit with current code"

$ git branch -D main
$ git branch -m main

$ git push -f origin main
