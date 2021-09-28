# NixOS configuration for my Dell Precision 5530

## Nix Configuration
* Automatic garbage collection enabled every day at 8:00am
* Enabled hydra.iohk.io binary cache
* Enabled NonFree packages

## Hardware Configuration
* Enabled Pulseaudio
* Enabled Bluetooth
* OpenGL with dri support enabled
* Proprietary nvidia driver with modesetting, persistence, power management (normal and fine grained), and prime offload

## Boot Configuration
* Use the grub2 bootloader with systemd-boot, using the nixos-grub2 theme, a decreased resolution, extra menu entries, and the ability to use LUKS partitions

## X Server Configuration
* Use the US keymap
* Use libinput to enable the touch pad
* Use the proprietary nvidia driver
* Enable the Gnome Display Manager with Wayland, nvidia support, and an auto suspend
* Enable the Gnome Desktop Environment with a wallpaper and default theming

## Networking Configuration
* Set the hostname
* Enable NetworkManager
* Enable DHCP with the default interface

## Miscellaneous
* Enable the fish shell
* Set the time zone to America/Chicago
* Enable printing
* Enable sound
* Install FiraCode and DroidSansMono
* Add my user with the fish shell and the groups "wheel" and "networkmanager" and a hashed password
* Setup custom shell commands to offload rendering to the nvidia card and to edit the system configuration in vscode
