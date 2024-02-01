FROM quay.io/toolbx-images/archlinux-toolbox:latest

LABEL com.github.containers.toolbox="true"

# First install reflector and update mirrors and keyring. I was getting key issues before this.
# RUN sudo pacman --noconfirm -S reflector
# RUN sudo reflector --save /etc/pacman.d/mirrorlist --country 'United States' --protocol https --latest 5
RUN sudo pacman-key --init
RUN sudo pacman -S --noconfirm archlinux-keyring

RUN sudo pacman --noconfirm -Syyu

# Disable root check for mkpkg and install yay
RUN sed -e '/exit \$E_ROOT/ s/^#*/#/' -i /usr/bin/makepkg
RUN git clone https://aur.archlinux.org/yay.git && cd yay && makepkg --noconfirm -si
# Add root check back to be safe
RUN sed -e '/exit \$E_ROOT/ s/^#//' -i /usr/bin/makepkg

