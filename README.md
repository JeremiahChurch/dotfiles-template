# Chezmoi dotfiles

https://www.chezmoi.io/

`chezmoi apply`

`chezmoi update` when you want to pull from remote

`chezmoi add ~/.ssh/config` when you make a local change

## setup new machine

### install

windows `winget install twpayne.chezmoi`

anywhere else `sh -c "$(curl -fsLS get.chezmoi.io)"`

### init

`chezmoi init --apply https://github.com/JeremiahChurch/dotfiles.git`
