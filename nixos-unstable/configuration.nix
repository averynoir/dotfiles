# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

####################################################################################################

  ## Imports. ##
  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./gnome.nix
      ./pcloud.nix
    ];

####################################################################################################

  ## Bootloader and Kernel configuration. ##
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_testing;
  
  # Kernel Modules:
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback # OBS Studio Virtual Camera.
  ];
    
  # Modprobe Configuration.
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';

  # Polkit.
  security.polkit.enable = true;

####################################################################################################

  ## AMDGPU ##
  
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Vulkan (RADV)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # HIP
  systemd.tmpfiles.rules = 
  let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];

  # OpenCL
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
    amdvlk
    driversi686Linux.amdvlk # AMDVLK for 32 bit applications
  ];

####################################################################################################

  ## Networking. ##
  
  networking.networkmanager.enable = true; # Enable networking
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hostName = "yourhostnamehere"; # Define your hostname.

  # Configure network proxy if necessary.
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Firewall.
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

####################################################################################################

  ## Time zone and localization ##
  
  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11.
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

####################################################################################################

  ## Audio. ##
  
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

####################################################################################################

  ## Users. ##
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rionyreva = {
    isNormalUser = true;
    description = "Avery Noir";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "render" "flatpak" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

####################################################################################################

  ## Packages. ##
  
  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  
  # Unnecessary tools.
  lolcat
  # nitch # Install via nix-env -iA nixos.nitch
  
  # System.
  neovim
  flatpak
  flatpak-builder
  gparted
  bottles
  distrobox

  # Security.
  yubioath-flutter
  keepassxc
  cryptomator

  # Sync and filesharing.
  megasync
  # pcloud # Installed via ./pcloud.nix
  github-desktop
  filezilla
  onionshare-gui
  qbittorrent
  localsend

  # Browser.
  brave
  librewolf
  tor-browser

  # Communication & Social.
  discord
    (pkgs.discord.override {
      # remove any overrides that you don't want
      # withOpenASAR = true;
      withVencord = true;
    })
  vesktop # Screensharing with audio on wayland
  whatsapp-for-linux
  session-desktop
  tutanota-desktop

  # Multimedia & Creative.
  pixelorama
  makemkv
  handbrake
  gimp
  gimpPlugins.gmic
  kdePackages.k3b
  kdePackages.ghostwriter
  # libsForQt5.ghostwriter # Install Qt5 version first if newest gives you errors.
  blender-hip
  orca-slicer
  kdePackages.kdenlive
  davinci-resolve-studio
  puddletag
  vlc
  mpv
  yt-dlp
  ffmpeg_7

  # Gaming.
  prismlauncher
  space-cadet-pinball
  lutris
    (lutris.override {
      extraLibraries = pkgs: [
        mangohud
        gamescope
        # List library dependencies here
      ];
      extraPkgs = pkgs: [
        # List package dependencies here
      ];
    })
  protonup-qt

  # Emulation.
  nestopia-ue
  snes9x-gtk
  mgba
  duckstation
  pcsx2
  ryujinx
  dolphin-emu
  rmg-wayland

  ];

####################################################################################################

  ## Programs and their configurations. ##
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  
  # Install firefox.
  # programs.firefox.enable = true;
  
  # My Traceroute.
  # programs.mtr.enable = true;

  # GNU Privacy Guard.
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  
  # Install steam.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Virt-manager
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

####################################################################################################

  ## List services that you want to enable: ##

  # Enable Zram.
  zramSwap.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  # Enable bluetooth.
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  
  # Yubikey.
  # Smartcard mode.
  services.pcscd.enable = true;
  
  # Enable Flatpaks.
  services.flatpak.enable = true;
  # Ensure Flathub is added as a Flatpak remote.
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
  
  # Mullvad VPN
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;
  
  # Distrobox.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

####################################################################################################

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

####################################################################################################

}
