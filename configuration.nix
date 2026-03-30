{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # For saving myself from headaches related to mason (nvim)
  programs.nix-ld.enable = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "i915" ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time / Locale
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  # Intel Graphics
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      vpl-gpu-rt
    ];
  };
  hardware.enableRedistributableFirmware = true;
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Input
  services.libinput.enable = true;

  # Docker
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # Zsh
  programs.zsh = {
    enable = true;
  };
  users.defaultUserShell = pkgs.zsh;

  # File Manager
  programs.thunar.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  users.users.gnix0 = {
    isNormalUser = true;
    extraGroups = [ 
	"wheel"
	"networkmanager"
	"docker"
	"video"
	"audio"
    ];
    shell = pkgs.zsh;
  };

  # Unfree
  nixpkgs.config.allowUnfree = true;

  # System Packages
  environment.systemPackages = with pkgs; [
	waybar
	grim
	slurp
	pavucontrol
	sway-contrib.grimshot
	wl-clipboard
	mako
	rofi
	swaylock
	swayidle
	brightnessctl
	mupdf
	alacritty
	tmux
	zsh
	pay-respects
	tree-sitter
	neovim
	git
	clang
	gcc
	gnumake
	cmake
	ripgrep
	fd
	fzf
	wget
	curl
	unzip
	tree
	btop
	jq
	brave
	vlc
	obs-studio
	imv
	docker-compose
	kubectl
	minikube
	kind
	go
	rustup
	jdk17
	jdk21
	jdk25
	maven
	gradle
	elixir
	erlang
	ruby
	bundler
	nodejs
  ];

  # Fonts
  fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
  ];

  # Default JAVA_HOME
  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  # NixOS
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";

}

