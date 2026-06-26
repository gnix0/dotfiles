{ config, pkgs, ... }:

{
	home.username = "gnix";
	home.homeDirectory = "/home/gnix";
	home.stateVersion = "25.11";

	home.sessionPath = [
		"${config.home.homeDirectory}/.config/emacs/bin"
	];

	home.sessionVariables = {
		TERMINAL = "ghostty";
		JAVA_HOME = "${pkgs.jdk25}/lib/openjdk";
	};

	programs.zsh = {
		enable = true;
		autosuggestion.enable = true;

		shellAliases = {
			rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
		};

		oh-my-zsh = {
			enable = true;
			theme = "robbyrussell";
			plugins = [ "git" "sudo" "docker" "docker-compose" ];
		};
	};

	programs.neovim = {
		enable = true;
		defaultEditor = true;
		vimAlias = true;
	};

	programs.java = {
		enable = true;
		package = pkgs.jdk25;
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
