FROM ghcr.io/azicen/desktop:latest

ENV TITLE="Clash Verge"

RUN exec s6-setuidgid abc \
        yay -Sy --noconfirm --needed \
            clash-verge-rev-bin && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/* \
        /var/lib/pacman/sync/* \
        /config/.cache/yay/*

COPY /root /

VOLUME /config/.local/share/io.github.clash-verge-rev.clash-verge-rev

EXPOSE 7897 9097
