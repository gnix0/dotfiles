{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Defines the hostname (and I am not a creative person lol).

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm = {
	enable = true;
	greeters.gtk.enable = true;
      };
      defaultSession = "none+i3";
    };
    desktopManager = {
      xterm.enable = false;
      gnome.enable = true;
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
	polybar
	i3status
	rofi
      ];
    };
  };

  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      polybar = pkgs.polybar.override {
	i3Support = true;
      };
    };
  };

  services.xserver.displayManager.gdm.enable = false;
  services.picom = {
    enable = true;
    backend = "xrender";
    vSync = true;
    settings = {
      opacity-rule = [
	"90:class_g = 'ghostty'"
      ];
    };
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account.
  users.users.gnix = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "uucp" "video" "audio" "dialout" "libvirtd" "input" ];
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
  };

  # programs.firefox.enable = true;
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "docker-28.5.2" ];

  # Enable Emacs daemon
  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  # JDKs
  environment.etc = {
    "jdks/java-8".source = pkgs.jdk8;
    "jdks/java-11".source = pkgs.jdk11;
    "jdks/java-17".source = pkgs.jdk17;
    "jdks/java-21".source = pkgs.jdk21;
    "jdks/java-25".source = pkgs.jdk25;
  };

  programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      glibc
      zlib
      openssl
      icu
      curl
      util-linux
  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
	emacs
	wget
	git
	ripgrep
	fd
	tree-sitter
	feh
	pcmanfm
	lxappearance
	adwaita-icon-theme
	discord
	flameshot
	stow
	zsh
	ghostty
	rofi
	pavucontrol
	xclip
	coreutils
	libvterm
	libtool
	gcc
	glibc
	libcxx
	gdb
	cmake
	gnumake
	libgcc
	clang
	clang-tools
	lld
	pkg-config
	pam_u2f
	ispell
	aspell
	aspellDicts.en
	sqlite
	bash
	libxml2
	go-tools
	gopls
	rustup
	rust-analyzer
	go
	lightdm
	fwupd
	obs-studio
	jdt-language-server
	lua-language-server
	nil
	maven
	gradle
	python3
	nodejs_22
	pnpm
	ruby
	libyaml
	openssl
	zlib
	elixir
	elixir-ls
	erlang
	docker-compose
	kubectl
	kubernetes-helm
	k9s
	dbeaver-bin
	tree
	jq
	yq
	zip
	unzip
	file
	which
	fzf
	htop
	btop
	fastfetch
	nerd-fonts.symbols-only
	mgba
	simple64
  ];

  virtualisation.docker.enable = true;

  fonts = {
    packages = with pkgs; [
      nerd-fonts.terminess-ttf
      nerd-fonts.blex-mono
      nerd-fonts.jetbrains-mono
      ibm-plex
      openmoji-color
    ];
    fontconfig = {
      defaultFonts = {
	sansSerif = [ "IBM Plex Sans" ];
	serif = [ "IBM Plex Serif" ];
	monospace = [ "Terminess Nerd Font" ];
	emoji = [ "OpenMoji Color" ];
      };
    };
  };

  programs.firefox = {
    enable = true;
    policies = {
      ExtensionSettings = {
        # Force-installs the DuckDuckGo Privacy Essentials extension
        "jid1-Zgo7gNsOww7HBw@jetpack" = {
          installation_mode = "force_installed";
          install_url = "https://mozilla.org";
        };
      };

    SearchEngines = {
      Default = "DuckDuckGo";
      PreventInstalls = false;
    };

      Preferences = {
	"browser.search.update" = false;
      };
    };
  };


  # Limit the number of generations kept in the boot menu
  boot.loader.systemd-boot.configurationLimit = 5;
  # Automate garbage collection to keep the drive clean.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes"];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable firmware update manager daemon.
  services.fwupd.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}

