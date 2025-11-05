

# Go to the logs folder
$ cd /Users/<USERNAME>/Library/Application Support/GitHub Desktop/logs

# Open the appropriate log file
# Locate the line that says "Dropped stash", which contains the hash address (commit id)
# i.e. 652aeef1df601351c24e172c464f3e6d56a0b605

# Restore the commit
$ git restore --source=652aeef1df601351c24e172c464f3e6d56a0b605 -- discareded.ipynb

# Or Restore it in a copy ++ This prevents overwriting the new commits
$ git show 652aeef1df601351c24e172c464f3e6d56a0b605:discareded.ipynb > recovered.ipynb

# Thanks to https://stackoverflow.com/questions/70442064/recover-dropped-stashed-changes-in-github-desktop-windows-10
