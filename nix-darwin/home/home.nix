

{ pkgs, config, lib, ... }:

let
  sshKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
in
{
  home.stateVersion = "23.11";

  programs.git = {
    enable = true;
    delta.enable = true;

    userName = "hugomardbrink";
    userEmail = "hugo@mardbrink.se";
    extraConfig = {
      pull.rebase = true;
      core = {
        editor = "${pkgs.neovim}/bin/nvim";
      };

    };
  };
 
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    
    oh-my-zsh = {
      enable = true;
      theme = "afowler";
      plugins = [ 
        "fzf"
        "zoxide"
        "git"
      ];
    };
    shellAliases = {
      ls = "ls --color";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
  home.file.".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/ghostty";

  home.file.".hushlogin".text = "";
  home.activation.createDevFolder = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/dev"
  '';

    home.activation.generateSshKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f "${sshKeyPath}" ]; then
        echo "Generating SSH key at ${sshKeyPath}..."
        mkdir -p "$(dirname "${sshKeyPath}")"
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "${sshKeyPath}" -N ""
        chmod 600 "${sshKeyPath}"
      else
        echo "SSH key already exists at ${sshKeyPath}, skipping."
      fi
'';
}
 
