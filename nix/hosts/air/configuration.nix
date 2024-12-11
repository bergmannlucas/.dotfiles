{
  pkgs,
  outputs,
  userConfig,
  ...
}: {
  # Add nix-homebrew configuration
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "${userConfig.name}";
    autoMigrate = true;
  };

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  # Nix settings
  nix.settings = {
    experimental-features = "nix-command flakes";
  };
  nix.package = pkgs.nix;

  # Enable Nix daemon
  services.nix-daemon.enable = true;

  # User configuration
  users.users.${userConfig.name} = {
    name = "${userConfig.name}";
    home = "/Users/${userConfig.name}";
  };

  # Add ability to use TouchID for sudo
  security.pam.enableSudoTouchIdAuth = true;

  # System settings
  system = {
     defaults = {
       menuExtraClock.Show24Hour = true;

       dock = {
        autohide = true;
        show-recents = false;
        mru-spaces = false;

        #wvous-tl-corner = 2; # top-left - Mission Control
        #wvous-tr-corner = 13; # top-right - Lock Screen
        #wvous-bl-corner = 3; # bottom-left - Application Windows
        #wvous-br-corner = 4; # bottom-right - Desktop

        persistent-apps = [
          "/Applications/Notion Calendar.app"
          "${pkgs.spotify}/Applications/Spotify.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
          "/Applications/Todoist.app"
          "${pkgs.slack}/Applications/Slack.app"
          "/Applications/Brave Browser.app"
          "/Applications/kitty.app"
          "${pkgs.vscode}/Applications/Visual Studio Code.app"
          "/Applications/Insomnia.app"
          "/Applications/Docker.app"
          "${pkgs.dbeaver-bin}/Applications/DBeaver.app"
          "/Applications/Another Redis Desktop Manager.app"
        ];
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        FXPreferredViewStyle = "clmv";
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      loginwindow.GuestEnabled = false;
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        KeyRepeat = 2;
      };
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [ 
    mkalias 
    zsh 
    oh-my-posh 
    tmux 
    neovim
    stow 
    ripgrep 
    fzf
    obsidian 
    gh 
    k9s
    vscode 
    yazi 
    hugo 
    btop 
    htop 
    stats
    zoom-us 
    wget 
    slack 
    rectangle 
    dbeaver-bin
    spotify
  ];

  # Zsh configuration
  programs.zsh.enable = true;

  # Fonts configuration
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  homebrew = {
    enable = true;
    brews = [ 
      "mas" 
      "awscli-local" 
      "pyenv" 
      "virtualenv" 
      "pyenv-virtualenv" 
    ];
    casks = [ 
      "aerospace"
      "kitty" 
      "docker" 
      "insomnia" 
      "another-redis-desktop-manager" 
      "todoist" 
      "notion-calendar" 
      "brave-browser"
      "logi-options+"
    ];
    taps = [
      "nikitabobko/tap"
    ];
    masApps = { 
      Vetero = 6449091332; 
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 5;
}

