FROM ubuntu:20.04
ARG LENS_VERSION

ENV DISPLAY=:0
ENV PORT=8080
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=mattipaksula/wait-for:sha-2a34cde /wait-for /usr/bin

RUN apt-get update && apt-get install -y \
  curl git \
  xvfb x11vnc \
  libnss3 libglib2.0-0 libgdk-pixbuf2.0-0 libgtk-3-0 libx11-xcb1 libasound2 libxss1 libgbm1 \
  && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get update && apt-get install -y nodejs

WORKDIR /opt
RUN git clone https://github.com/novnc/websockify-js.git \
  && cd websockify-js/websockify && npm install

RUN curl -LO https://github.com/lensapp/lens/releases/download/v${LENS_VERSION}/Lens-${LENS_VERSION}.AppImage \
  && chmod +x Lens-${LENS_VERSION}.AppImage \
  && ./Lens-${LENS_VERSION}.AppImage --appimage-extract \
  && rm -rf Lens-${LENS_VERSION}.AppImage \
  && mv /opt/squashfs-root /opt/lens

WORKDIR /app
COPY app .

ENTRYPOINT [ "/app/entrypoint.sh" ]
