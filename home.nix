{ config, pkgs, ... }:

let
  LS_COLORS = pkgs.fetchgit {
    url = "https://github.com/trapd00r/LS_COLORS";
    rev = "6fb72eecdcb533637f5a04ac635aa666b736cf50";
    sha256 = "0czqgizxq7ckmqw9xbjik7i1dfwgc1ci8fvp1fsddb35qrqi857a";
  };
  ls-colors = pkgs.runCommand "ls-colors" { } ''
    mkdir -p $out/bin $out/share
    ln -s ${pkgs.coreutils}/bin/ls $out/bin/ls
    ln -s ${pkgs.coreutils}/bin/dircolors $out/bin/dircolors
    cp ${LS_COLORS}/LS_COLORS $out/share/LS_COLORS
  '';

  #shell-prompt = pkgs.callPackage ./shell-prompt { };
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "sspeaks";
  home.homeDirectory = "/home/sspeaks";
  home.packages = [ pkgs.ripgrep pkgs.git ls-colors 
  #shell-prompt 
  pkgs.starship
  pkgs.shellcheck ];
  home.sessionVariables = {
    EDITOR = "vim";
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      hostname = {
        disabled = true;
      };
      line_break = {
        disabled = true;
      };
      username = {
        format = "[$user]($style) ";
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
      };
    }; 
  };


  programs.neovim = {
      enable = true;
      vimAlias = true;
      extraConfig = ''
        " Full config: when writing or reading a buffer, and on changes in insert and
        " normal mode (after 500ms; no delay when writing).
"        call neomake#configure#automake('nrwi', 500)
        '';
      plugins = with pkgs.vimPlugins; [
        # Syntax / Language Support ##########################
        ale
        vim-nix
        vim-pandoc # pandoc (1/2)
        vim-pandoc-syntax # pandoc (2/2)
      ];
    };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;

      shellAliases = {
        ls = "ls --color=auto -F";
        rcon = "docker exec -i mc rcon-cli";
        logs = "docker logs mc -f --tail 100";
        admin = "screen -c mcadmin.screenrc";
      };
      initExtraBeforeCompInit = ''
        eval $(${pkgs.coreutils}/bin/dircolors -b) 
        ${builtins.readFile ./pre-compinit.zsh}
      '';
      initExtra = builtins.readFile ./post-compinit.zsh;

      plugins = [
        {
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.6.3";
            sha256 = "1h8h2mz9wpjpymgl2p7pc146c1jgb3dggpvzwm9ln3in336wl95c";
          };
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "be3882aeb054d01f6667facc31522e82f00b5e94";
            sha256 = "0w8x5ilpwx90s2s2y56vbzq92ircmrf0l5x8hz4g1nx3qzawv6af";
          };
        }
    ];
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
