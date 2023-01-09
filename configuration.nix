# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <nixos-hardware/common/pc/ssd>
      <nixos-hardware/common/gpu/nvidia>
    ];
  
  nixpkgs.config.allowUnfree = true;  	
  
  # Use the systemd-boot EFI boot loader.

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
	  
    loader = {
	    systemd-boot = {
	    	enable = true;
	    	configurationLimit = 6;
	    };
	    efi = {
	    	canTouchEfiVariables = true;
	    	efiSysMountPoint = "/boot";	
	    };
	  };
	  plymouth.enable = true;
  };

  networking.hostName = "x99"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  security.rtkit.enable = true;

  # Enable sound.
  
  sound.enable = true;
  hardware.pulseaudio.enable = false; 
  
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
  

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fennecs = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox-wayland
      tdesktop
      discord 
      ghc 
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          jnoortheen.nix-ide
          ms-python.python
          ms-vscode.hexeditor
          justusadam.language-haskell
          haskell.haskell
        ]; 
      })
      unzip
      prismlauncher
      jdk19
      sage
      git 
      haskellPackages.pointfree
      google-chrome
     ];
  };
  
  nixpkgs.overlays = [
      (import (builtins.fetchTarball "https://github.com/PrismLauncher/PrismLauncher/archive/develop.tar.gz")).overlay
      (self: super: {
       discord = super.discord.overrideAttrs (
         _: { src = builtins.fetchTarball https://discord.com/api/download?platform=linux&format=tar.gz; }
       );
      })
      (final: prev: {
      discord =
        final.symlinkJoin {
            name = "discord";
            paths = [ prev.discord ];
            nativeBuildInputs = [ final.makeWrapper ];

            postBuild = ''
                wrapProgram $out/bin/discord --add-flags "--use-gl=desktop"
                wrapProgram $out/bin/Discord --add-flags "--use-gl=desktop"
            '';

            passthru.unwrapped = prev.discord;

            meta = {
                inherit (prev.discord.meta) homepage description longDescription maintainers;
                mainProgram = "discord";
            };
        };
      })
  ];


  
  programs.steam.enable = true;
  programs.zsh.enable = true;
  programs.starship.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  
  
  environment.systemPackages = with pkgs; [
    nano
    wget
    gnomeExtensions.dash-to-panel
    gnomeExtensions.appindicator
    gnomeExtensions.maximize-to-empty-workspace
  ];
  

  environment.gnome.excludePackages = (with pkgs; [ 
    gnome-tour
    gnome.gnome-music
    gnome.cheese
  ]);
  
  environment.sessionVariables.NIXOS_OZONE_WL = "1";


  networking.firewall.enable = true;
  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
  };

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

