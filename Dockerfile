ARG CI_REGISTRY_IMAGE
ARG DAVFS2_VERSION
FROM ${CI_REGISTRY_IMAGE}/nc-webdav:${DAVFS2_VERSION}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
#ARG APP_VERSION

#LABEL app_version=$APP_VERSION

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl libsm6 libxt6 libpulse-mainloop-glib0 libxcb-icccm4 libqt5gui5 && \
    curl -J -O -L https://download.slicer.org/bitstream/60add706ae4540bf6a89bf98 && \
    mkdir ./install && \
    tar xzf Slicer-*-linux-amd64.tar.gz -C ./install && \
    mv ./install/Slicer-*-linux-amd64 ./install/Slicer && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SHELL="no"
ENV APP_CMD="/apps/${APP_NAME}/install/Slicer/Slicer"
ENV PROCESS_NAME="Slicer"
ENV DIR_ARRAY=".config/NA-MIC"

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
