{ config, pkgs, ... }:

{
	home.username = "gnix";
	home.homeDirectory = "/home/gnix";
	home.stateVersion = "25.11";

	home.sessionVariables = {
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
		};
	};
}
