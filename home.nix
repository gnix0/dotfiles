{ pkgs, ... }:

{
  home.username = "gnix0";
  home.homeDirectory = "/home/gnix0";
  home.stateVersion = "25.11";

  # Shell
  programs.git.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      dev = "tmux-sessionizer";
    };

    oh-my-zsh = {
	enable = true;
	plugins = [ "git" "sudo" ];
	theme = "robbyrussell";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.dotnet/tools"
    "$HOME/.npm-global/bin"
  ];

  # Desktop apps
  programs.alacritty.enable = true;

  # Terminal
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    prefix = "C-a";
    escapeTime = 0;
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    extraConfig = ''
      set -as terminal-overrides ',*:Tc'
      set -g focus-events on
      set -g pane-base-index 0
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf
      bind-key C-l send-keys -R C-l
      bind x kill-pane
      bind X kill-session
      unbind %
      bind | split-window -h
      unbind '"'
      bind - split-window -v
      bind -r C-h resize-pane -L 10
      bind -r C-j resize-pane -D 10
      bind -r C-k resize-pane -U 10
      bind -r C-l resize-pane -R 10
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R
      bind [ copy-mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection
      unbind -T copy-mode-vi MouseDragEnd1Pane
      set -g status-style bg='#1f1f28',fg='#dcd7ba'
    '';
  };
}
