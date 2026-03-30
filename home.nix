{ config, pkgs, ... }:

{
	home.username = "gnix0";
	home.homeDirectory = "/home/gnix0";

	programs.git.enable = true;

	programs.zsh = {
	    enable = true;
	    enableCompletion = true;
	    initContent = ''
	      DISABLE_MAGIC_FUNCTIONS=true
	      DISABLE_AUTO_UPDATE=true
	      ZSH_DISABLE_COMPFIX=true
	    '';
	    shellAliases = {
	      vim = "nvim";
	      dev = "tmux-sessionizer";
	      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
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
 
	programs.pay-respects.enable = true;

	programs.alacritty.enable = true;

	programs.tmux = {
	  enable = true;
	  terminal = "tmux-256color";
	  prefix = "C-a";
	  escapeTime = 0;
	  baseIndex = 1;
	  mouse = true;
	  keyMode = "vi";
	  extraConfig = ''
	    # Truecolor
	    set -as terminal-overrides ',*:Tc'

	    # Neovim focus events
	    set -g focus-events on

	    # Pane base index
	    set -g pane-base-index 0

	    # Quick refresh
	    unbind r
	    bind r source-file ~/.config/tmux/tmux.conf

	    # Clear panel
	    bind-key C-l send-keys -R C-l

	    # Kill pane/session
	    bind x kill-pane
	    bind X kill-session

	    # Splits
	    unbind %
	    bind | split-window -h
	    unbind '"'
	    bind - split-window -v

	    # Resize panes
	    bind -r C-h resize-pane -L 10
	    bind -r C-j resize-pane -D 10
	    bind -r C-k resize-pane -U 10
	    bind -r C-l resize-pane -R 10

	    # Navigate panes
	    bind -r h select-pane -L
	    bind -r j select-pane -D
	    bind -r k select-pane -U
	    bind -r l select-pane -R

	    # Copy mode vim style
	    bind [ copy-mode
	    bind-key -T copy-mode-vi 'v' send -X begin-selection
	    bind-key -T copy-mode-vi 'y' send -X copy-selection
	    unbind -T copy-mode-vi MouseDragEnd1Pane

	    # Status line
	    set -g status-style bg='#161616',fg='#f2f4f8'
	  '';
	};

	home.stateVersion = "25.11";
}
