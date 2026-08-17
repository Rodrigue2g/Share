# SSH Key Generation

Generate a named SSH key without overwriting an existing default key, add it to the SSH agent, and copy the public key for use with GitHub, GitLab, or a VPS.

## Generate a Key

Replace `<name>` with a short label for the machine, account, or server.

```sh
ssh-keygen -t ed25519 -C "rodrigue2g@example.com" -f ~/.ssh/id_ed25519_<name>
```

## Add the Key to the Agent

```sh
ssh-add ~/.ssh/id_ed25519_<name>
```

## Copy the Public Key

On macOS:

```sh
pbcopy < ~/.ssh/id_ed25519_<name>.pub
```

## Copy the Key to a VPS

```sh
ssh-copy-id -i ~/.ssh/id_ed25519_<name>.pub <username>@<vps-ip>
```

## Disable Password Login on the VPS

Edit the SSH daemon config:

```sh
sudo nano /etc/ssh/sshd_config
```

Set:

```txt
PasswordAuthentication no
```

Restart SSH:

```sh
sudo systemctl restart ssh
```
