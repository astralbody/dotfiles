FROM archlinux:base-devel

RUN pacman -Syu --noconfirm
ARG user=archie
RUN useradd --system --create-home $user \
	&& echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
USER $user
WORKDIR /home/$user
RUN mkdir -p /home/$user/.dotfiles/dotfiles
COPY . /home/$user/.dotfiles/dotfiles

ENTRYPOINT ["./.dotfiles/dotfiles/install.sh"]
