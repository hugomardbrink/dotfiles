{
  description = "Hugo's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager}:
  let
   configuration = { pkgs, inputs, config, ... }: {
	
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      system.primaryUser = "hugom";

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
          zsh
          oh-my-zsh
          zsh-autocomplete
          zsh-autosuggestions
          zsh-syntax-highlighting
          fzf
          zoxide
          git
          neovim
          htop
          curl
          odin
          zig
          clang
          rustup
          python3
          go
          jdk
          kotlin
          maven
          gradle
          tree
          docker
          postgresql
          ripgrep
          cmake
          neofetch
          yabai
          skhd
          tree-sitter
          xclip
          openssh
          flyctl
          libiconv
          pkg-config
      ];
      environment.variables = {
        LIBRARY_PATH = "${pkgs.libiconv}/lib";
        C_INCLUDE_PATH = "${pkgs.libiconv}/include";
    };
    
      homebrew = {
        enable = true;
        brews = [ 
          "mas"
          "manim"
        ];
        casks = [ 
          "ghostty"
	      "zen-browser"
	      "protonvpn"
	      "proton-pass"
          "figma"
          "spotify"
        ];
        masApps = {
            "Xcode" = 497799835;
            "Giphy Capture" = 668208984;
        };

        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono 
          pkgs.nerd-fonts.fira-code
          pkgs.fira
      ];

      users.users.hugom = {
        home = "/Users/hugom";
      };

      system.activationScripts.application.text = let
        env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
            # Set upp applications.
            echo "Setting up /Applications..." >&2
            rm -rf /Applications/Nix\ Apps
            mkdir -p /Applications/Nix\ Apps
            find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
            while read src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            done
        '';

      security.pam.services.sudo_local.touchIdAuth = true;

      system.defaults = {
          dock.autohide = true;
          dock.persistent-apps = [
              "/Applications/Proton Pass.app"
              "/Applications/ProtonVPN.app"
              "/Applications/Ghostty.app"
              "/Applications/Zen.app"
              "/Applications/Xcode.app/Contents/Applications/Instruments.app/"
              "/Applications/GIPHY CAPTURE.app/"
              "/Applications/Figma.app/"
          ];
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.ApplePressAndHoldEnabled = false;
        NSGlobalDomain.InitialKeyRepeat = 12;
        NSGlobalDomain.KeyRepeat = 2;
        screencapture.target = "clipboard";
        dock.tilesize = 48;
      };

    services = {
        yabai = {
          enable = true;
          enableScriptingAddition = true;

          extraConfig = ''       
            yabai -m rule --add app="^System Settings$"    manage=off
            yabai -m rule --add app="^System Information$" manage=off
            yabai -m rule --add app="^System Preferences$" manage=off
            yabai -m rule --add title="Preferences$"       manage=off
            yabai -m rule --add title="Settings$"          manage=off
            yabai -m rule --add title="Proton Pass$"       manage=off
            yabai -m rule --add title="ProtonVPN$"         manage=off
            yabai -m rule --add title="^QuickTime Player$" manage=off
            yabai -m rule --add title="Spotify$"           manage=off
          '';
          config = {
              layout = "bsp";
              window_placement    = "second_child";
              top_padding         = 10;
              bottom_padding      = 10;
              left_padding        = 10;
              right_padding       = 10;
              window_gap          = 10;
            };
        };
    };

    services.skhd = {
    enable = true;
    skhdConfig = ''
      # open terminal
      alt - return : open -a ghostty -n
             
      # close focused window
      shift + alt - q : yabai -m window --close
             
      # focus window
      alt - h : yabai -m window --focus west || yabai -m display --focus west
      alt - j : yabai -m window --focus south || yabai -m display --focus south
      alt - k : yabai -m window --focus north || yabai -m display --focus north
      alt - l : yabai -m window --focus east || yabai -m display --focus east
            
      # swap window
      alt + shift - h : yabai -m window --swap west || $(yabai -m window --display west; yabai -m display --focus west)
      alt + shift - j : yabai -m window --swap south || $(yabai -m window --display south; yabai -m display --focus south)
      alt + shift - k : yabai -m window --swap north || $(yabai -m window --display north; yabai -m display --focus north)
      alt + shift - l : yabai -m window --swap east || $(yabai -m window --display east; yabai -m display --focus east)

      # warp window
      alt + ctrl + shift - h : yabai -m window --warp west || $(yabai -m window --display west; yabai -m display --focus west)
      alt + ctrl + shift - j : yabai -m window --warp south || $(yabai -m window --display south; yabai -m display --focus south)
      alt + ctrl + shift - k : yabai -m window --warp north || $(yabai -m window --display north; yabai -m display --focus north)
      alt + ctrl + shift - l : yabai -m window --warp east || $(yabai -m window --display east; yabai -m display --focus east)
             
      # Resize windows
      lctrl + alt - h : yabai -m window --resize left:-50:0; \
                        yabai -m window --resize right:-50:0
      lctrl + alt - j : yabai -m window --resize bottom:0:50; \
                        yabai -m window --resize top:0:50
      lctrl + alt - k : yabai -m window --resize top:0:-50; \
                        yabai -m window --resize bottom:0:-50
      lctrl + alt - l : yabai -m window --resize right:50:0; \
                        yabai -m window --resize left:50:0

      # create space and follow focus
      shift + alt - n : yabai -m space --create && \
                        index="$(yabai -m query --spaces --display | jq 'map(select(."is-native-fullscreen" == false))[-1].index')" && \
                        yabai -m window --space "''${index}" && \
                        yabai -m space --focus "''${index}"

      # destroy space and focus previous
      shift + alt - d : yabai -m space --destroy && \
                        index="$(yabai -m query --spaces --display | jq 'map(select(."is-native-fullscreen" == false))[-1].index')" && \
                        yabai -m space --focus "''${index}"


      # Equalize size of windows
      shift + alt - e : yabai -m space --balance
             
      # set insertion point for focused container
      ctrl + alt - h : yabai -m window --insert west
      ctrl + alt - j : yabai -m window --insert south
      ctrl + alt - k : yabai -m window --insert north
      ctrl + alt - l : yabai -m window --insert east
             
      # toggle window fullscreen
      alt - f : yabai -m window --toggle zoom-fullscreen
             
      # toggle window native fullscreen
      shift + alt - f : yabai -m window --toggle native-fullscreen
             
      # toggle window split type
      alt - e : yabai -m window --toggle split
             
      # float / unfloat window and center on screen
      alt - t : yabai -m window --toggle float;\
                yabai -m window --grid 4:4:1:1:2:2

      # toggle sticky(+float), topmost, picture-in-picture
      alt - p : yabai -m window --toggle sticky --toggle pip
             
      # mission control
      cmd - 3 : yabai -m space --toggle mission-control
      f3 : yabai -m space --toggle mission-control

      # restart
      ctrl + alt + cmd - r : launchctl kickstart -k gui/''${UID}/org.nixos.yabai && launchctl kickstart -k gui/''${UID}/org.nixos.skhd
    '';
  };

};

  in
  {
    darwinConfigurations."air" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "hugom";
          };
        }
	inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.hugom = import ./home/home.nix;
        }

      ];

    };
  };
}
