FROM ghcr.io/azicen/debian-desktop:latest

ARG TARGETARCH
ARG VERSION

ENV TITLE="Clash Verge"

ADD https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v${VERSION}/Clash.Verge_${VERSION}_${TARGETARCH}.deb /tmp/clash-verge.deb

RUN apt update && \
    apt --fix-broken install -y --no-install-recommends \
        /tmp/clash-verge.deb && \
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

VOLUME /config/.local/share/io.github.clash-verge-rev.clash-verge-rev

EXPOSE 7897 9097
