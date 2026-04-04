{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "i915" ];

  # Host
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;

  # Intel graphics
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      vpl-gpu-rt
    ];
  };

  # Wayland session
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Desktop services
  services.libinput.enable = true;
  programs.thunar.enable = true;
  programs.dconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;

  # Containers
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # User
  users.users.gnix0 = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "video"
      "audio"
    ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # Shell
    zsh
    tmux
    git
    wget
    curl
    unzip
    tree
    btop
    jq
    fd
    fzf
    ripgrep

    # Wayland desktop
    alacritty
    waybar
    rofi
    mako
    wl-clipboard
    grim
    slurp
    satty
    sway-contrib.grimshot
    brightnessctl
    pavucontrol
    qdirstat
    iwgtk
    wttrbar
    xdg-desktop-portal-gtk
    alsa-utils

    # Browsing and media
    brave
    vlc
    obs-studio
    imv
    mupdf

    # Editors and docs
    emacs-pgtk
    pandoc
    sqlite
    libtool
    shellcheck
    aspell
    aspellDicts.en

    # C and build tools
    clang
    clang-tools
    gcc
    gnumake
    cmake
    glslang

    # Go
    go
    gopls
    gotools
    delve
    golangci-lint
    gomodifytags
    gotests
    gore
    gofumpt

    # Rust
    rustup

    # JVM
    jdk17
    jdk21
    jdk25
    maven
    gradle
    ktlint

    # Elixir and Erlang
    elixir
    erlang

    # Ruby
    ruby
    bundler

    # JavaScript
    nodejs

    # Haskell
    haskell-language-server
    haskellPackages.hoogle
    cabal-install

    # Zig
    zig
    zls

    # Infra
    docker-compose
    kubectl
    minikube
    kind
    ansible
    terraform

    # Nix
    nixfmt-rfc-style
    shfmt

    # Small tools
    gum
    timer
    lolcat
    libnotify
    pay-respects
    tree-sitter
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.terminess-ttf
  ];

  # Java
  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  system.stateVersion = "25.11";
}
