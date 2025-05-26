# Dotfiles

## Bootstrap computer

### Change system names
set user to "hugom", hostname to "air"

### Partially disable SIP
[Guide](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection)

### Install determine nix
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```
Note: 
Use upstream nix
Restart shell

### Install nix flake
```bash
cd nix-darwin
nix run nix-darwin --extra-experimental-features "nix-command flakes"  -- switch --flake .
source ~/.zshrc
sudo darwin-rebuild switch --flake .

```
Note: 
Restart computer

### Add ssh key

## Features
- yabai
- skhd
- zsh + oh-my-zsh
- comprehensive nvim configuration
- ghostty
- proton vpn + pass

## Todo
- improve java dev environment in nvim
