if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_add_path ~/.config/emacs/bin
    set -gx EMACSDIR ~/.config/emacs
end

set -U fish_greeting ""
starship init fish | source

abbr -a rebuild "sudo nixos-rebuild switch --flake /etc/nixos#nixos"
