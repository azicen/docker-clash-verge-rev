FROM ghcr.io/azicen/debian-desktop:latest

ARG TARGETARCH
ARG VERSION

ENV TITLE="Clash Verge"

ADD https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v${VERSION}/Clash.Verge_${VERSION}_${TARGETARCH}.deb /tmp/clash-verge.deb

RUN apt update && \
    apt --fix-broken install -y --no-install-recommends \
        /tmp/clash-verge.deb && \
    apt install -y --no-install-recommends \
        libayatana-appindicator3-1 \
        python3-xdg && \
    apt autoremove -y && \
    apt autoclean -y && \
    apt clean && \
    rm -rf \
        /config/.cache \
        /config/.launchpadlib \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY /root /

RUN find /etc/cont-init.d /etc/s6-overlay /etc/xdg /defaults -type f -exec sed -i 's/\r$//' {} + \
    && find /etc/s6-overlay -type f -name run -exec chmod +x {} +

VOLUME /config/.local/share/io.github.clash-verge-rev.clash-verge-rev

EXPOSE 7897 9097
