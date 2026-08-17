#! bin/bash

# Generate a new ssh key (without overwriting any exisitng one)
$ ssh-keygen -t ed25519 -C "rodrigue2g@example.com" -f ~/.ssh/id_ed25519_<name>

# Add the key to your ssh agent
$ ssh-add ~/.ssh/id_ed25519_<name>

# You can then copy the public key generated
$ pbcopy < ~/.ssh/id_ed25519_<name>.pub

# To directly copy the pk to the vps:
$ ssh-copy-id -i ~/.ssh/id_ed25519_<name>.pub <username>@<vps-ip>

# Then on the vps, edit the SSH config
$ sudo nano /etc/ssh/sshd_config

# Find and set:
PasswordAuthentication no

# Then restart SSH
$ sudo systemctl restart ssh
