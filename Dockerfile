ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl libsm6 libxt6 libpulse-mainloop-glib0 libxcb-icccm4 \
    libxdamage1 libnss3 libqt5gui5 libxcomposite1 libxrandr2 \
    libxcursor1 libxi6 libasound2 libgssapi-krb5-2 libgomp1 && \
    curl -sSJOL "http://download.slicer.org/download?os=linux&stability=release&version=${APP_VERSION}" && \
    mkdir ./install && \
    tar xzf Slicer-*-linux-amd64.tar.gz -C ./install && \
    mv ./install/Slicer-*-linux-amd64 ./install/Slicer && \
    rm Slicer-*-linux-amd64.tar.gz && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/install/Slicer/Slicer"
ENV PROCESS_NAME="Slicer"
ENV APP_DATA_DIR_ARRAY=".config/NA-MIC"
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
