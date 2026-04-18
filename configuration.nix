{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

#  boot.kernelPackages = pkgs.linuxPackages_testing;
#  boot.kernelPatches = [
#    {
#      name = "r8169-qstats";
#      patch = ./r8169-qstats.patch;
#    }
#  ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelParams = [
    "i915.enable_psr=0"
    "i915.enable_fbc=0"
  ];

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

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      zstd
      openssl
      curl
      libxml2
      xz
      bzip2
      ncurses
      libffi
      readline
      sqlite
      icu
    ];
  };  

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
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    XDG_SESSION_TYPE = "wayland";
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
      "dialout"
    ];
  };

  # Neovim
  programs.neovim = {
	enable = true;
	defaultEditor = true;
	vimAlias = true;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # Shell
    zsh
    tmux
    gitFull
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
    discord
    alsa-utils

    # Browsing and media
    brave
    vlc
    obs-studio
    imv
    mupdf

    # Editors and docs
    neovim
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
    jetbrains.goland

    # Rust
    rustup
    rust-analyzer
    jetbrains.rust-rover

    # Java
    maven
    gradle
    ktlint
    jdt-language-server
    google-java-format
    jetbrains.idea

    # Elixir and Erlang
    elixir
    erlang
    elixir-ls

    # Ruby
    ruby
    ruby-lsp
    rubyPackages.rubocop
    bundler

    # JavaScript
    nodejs
    nodePackages_latest.typescript-language-server
    nodePackages_latest.bash-language-server
    nodePackages_latest.vscode-langservers-extracted
    nodePackages_latest.yaml-language-server
    dockerfile-language-server
    docker-compose-language-service
    prettierd
    eslint_d

    # Haskell
    haskell-language-server
    haskellPackages.hoogle
    cabal-install

    # Zig
    zig
    zls

    # Python
    python3

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
    nil
    nixd

    # Lua
    stylua

    # Small tools
    gum
    timer
    lolcat
    libnotify
    pay-respects
    tree-sitter

    # Networking / NIC testing
    ethtool
    iproute2
    pciutils
    usbutils
    iperf3
    tcpdump
    kmod

    # Kernel build dependencies
    llvm
    lld
    bc
    bison
    flex
    perl
    rsync
    cpio
    ncurses
    pkg-config
    openssl
    elfutils
    pahole

    # Kernel/networking workflw
    b4
    trace-cmd

    # OS development
    qemu
    OVMF
    limine
    xorriso
    mtools
    nasm
    gdb
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
