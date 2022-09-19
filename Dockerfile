FROM archlinux:base-devel

RUN pacman -Syu --noconfirm
ARG user=archie
RUN useradd --system --create-home $user \
	&& echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
USER $user
WORKDIR /home/$user
RUN mkdir -p Projects/dotfiles
COPY . Projects/dotfiles

ENTRYPOINT ["./Projects/dotfiles/install.sh"]
