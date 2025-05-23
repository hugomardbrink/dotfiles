{
  description = "Hugo's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = [ 
          pkgs.neovim
          pkgs.htop
          pkgs.zig
      ];
    
      homebrew = {
        enable = true;
        brews = [ "mas" ];
        casks = [ 
          "ghostty"
          "zen-browser"
        ];
        masApps = {
            "Xcode" = 497799835;
            "Proton VPN" = 1437005085;
            "Proton Pass" = 6443490629;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono 
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      system.primaryUser = "hugom";


      system.defaults = {
        dock.autohide = true;
        dock.persistent-apps = [
          "/Applications/ProtonVPN.app"
          "/Applications/Proton Pass.app"
          "/Applications/Ghostty.app"
          "/Applications/Zen Browser.app"
        ];
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.KeyRepeat = 2;
      };


      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

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

    };
  in
  {
    # Build darwin flake using:
    darwinConfigurations."hugo" = nix-darwin.lib.darwinSystem {
      modules = [ 

        configuration 
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "hugom";

            autoMigrate = true;
          };
        }

      ];

    };
  };
}
