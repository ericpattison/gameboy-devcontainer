FROM archlinux:latest AS base
RUN pacman -Syu --noconfirm && pacman -S --noconfirm cmake make clang

FROM base AS build

WORKDIR /src
ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITARM=/opt/devkitpro/devkitARM
ENV DEVKITPPC=/opt/devkitpro/devkitPPC

RUN pacman -S --noconfirm git bison libpng musl wget
# GAMEBOY DEV
RUN git clone https://github.com/gbdev/rgbds.git
RUN cd rgbds && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build && cmake --install build --prefix /out/rgbds

#GBA/NDS DEV
RUN pacman-key --init && pacman-key --recv BC26F752D25B92CE272E0F44F7FD5492264BB9D0 --keyserver keyserver.ubuntu.com && pacman-key --lsign BC26F752D25B92CE272E0F44F7FD5492264BB9D0
RUN wget https://pkg.devkitpro.org/devkitpro-keyring.pkg.tar.xz && pacman -U --noconfirm devkitpro-keyring.pkg.tar.xz
RUN echo $'[dkp-libs]\n\
Server = https://pkg.devkitpro.org/packages\n\
[dkp-linux]\n\
Server = https://pkg.devkitpro.org/packages/linux/$arch/' >> /etc/pacman.conf
RUN pacman -Syu --noconfirm && pacman -S --noconfirm gba-dev nds-dev 3ds-dev

FROM base AS devcontainer

ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITARM=/opt/devkitpro/devkitARM
ENV DEVKITPPC=/opt/devkitpro/devkitPPC

ENV PATH "$PATH:/opt/devkitpro/tools/bin"

COPY --from=build /out/rgbds/bin/ /usr/local/bin/
COPY --from=build /opt/devkitpro/ /opt/devkitpro/