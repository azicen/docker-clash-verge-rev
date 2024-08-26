FROM library/debian:12-slim AS download

ARG ARCH
ARG VERSION

ADD https://github.com/clash-verge-rev/clash-verge-rev/releases/download/alpha/clash-verge_${VERSION}_${ARCH}.deb clash-verge.deb
ADD https://github.com/clash-verge-rev/clash-verge-rev/releases/download/dependencies/libwebkit2gtk-4.0-37_2.43.3-1_${ARCH}.deb libwebkit2gtk.deb
ADD https://github.com/clash-verge-rev/clash-verge-rev/releases/download/dependencies/libjavascriptcoregtk-4.0-18_2.43.3-1_${ARCH}.deb libjavascriptcoregtk.deb


FROM ghcr.io/linuxserver/webtop:ubuntu-xfce

COPY --from=download clash-verge.deb clash-verge.deb
COPY --from=download libwebkit2gtk.deb libwebkit2gtk.deb
COPY --from=download libjavascriptcoregtk.deb libjavascriptcoregtk.deb
RUN apt update && apt install -y --no-install-recommends \
        ./clash-verge.deb \
        ./libwebkit2gtk.deb \
        ./libjavascriptcoregtk.deb \
        fonts-noto-cjk && \
    apt autoremove -y && \
    apt autoclean -y && \
    apt clean && \
    rm \
        clash-verge.deb \
        libwebkit2gtk.deb \
        libjavascriptcoregtk.deb

RUN mkdir -p /config/.config/autostart
COPY ./root /

RUN chmod 755 /config/.config/autostart
RUN chmod 644 /config/.config/autostart/clash-verge.desktop
RUN chown abc:abc -R /config/.config/autostart

VOLUME /config/.local/share/io.github.clash-verge-rev.clash-verge-rev

EXPOSE 7897
