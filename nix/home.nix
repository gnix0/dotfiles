{ config, pkgs, ... }:

{
	home.username = "gnix";
	home.homeDirectory = "/home/gnix";
	home.stateVersion = "25.11";

	home.sessionVariables = {
		EMACSDIR = "$HOME/.config/emacs";
		EDITOR = "emacsclient";
		VISUAL = "emacsclient";
		TERMINAL = "ghostty";
		BROWSER = "google-chrome-stable";
	};

	gtk = {
	  enable = true;
	  theme = {
	    name = "Adwaita-dark";
	    package = pkgs.gnome-themes-extra;
	  };
	  iconTheme = {
	    name = "Adwaita";
	    package = pkgs.adwaita-icon-theme;
	  };
	};

	programs.git = {
		enable = true;
		userName = "Gustavo Arantes";
		userEmail = "dev.gustavoa@gmail.com";

		extraConfig = {
			init.defaultBranch = "main";
			core.editor = "emacsclient";
		};
	};

	programs.emacs.enable = true;
	services.emacs = {
		enable = true;
		package = pkgs.emacs;
	};
}
