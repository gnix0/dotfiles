# Dotfiles

For terminal-first development, run `fwdev` from `~/.local/bin` (Stow package
`dev`). It prepares new/existing projects and reviewed direnv environments while
leaving builds, target selection, flashing and debugging explicit.

## Keyboard Layout (Kinesis Advantage 360)

![kinesis layout](./assets/kinesis_layout.png)

---

## Dotfiles organization

The directories and files are organized to be managed with **GNU Stow**:

```bash
├── alacritty
├── emacs
├── fastfetch
├── hypr
├── .tmux.conf
├── waybar
└── .zshrc
```

To apply the configurations on a Unix-like system that follows the **Filesystem Hierarchy Standard**,
make sure **stow** is installed:

```bash
# e.g., installation on Arch Linux
sudo pacman -S stow

# Clone the repository and apply the desired configuration(s)
git clone https://github.com/gnix0/dotfiles.git

cd ~/path/to/local/repo

stow <app_dir_name>
```

> [!NOTE]
> The configs here are tailored to my own workflows and the way I like doing things. Feel free to use them as a reference or inspiration, but do not expect them to work out of the box on your machine, or for the tools, themes, keybinds, etc. here to suit your own preferences. Building your own configuration is one of the best ways to learn the tools you use and create an environment that feels great to work in. Everything here is a result of years of experience and just using sh*t everyday. I did not settle on my editor first try, nor did I settle on my binds the 10th time. Hell, I didn't settle on the font the 50th time (probably more). I suggest you do the same. Enjoy your own journey! xD
