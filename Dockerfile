FROM node:12-buster-slim

# Allow to pass extra options to the npm run build
# eg: --light --light-fr to not build all client languages
#     (speed up build time if i18n is not required)
ARG NPM_RUN_BUILD_OPTS

# Install dependencies and create user
RUN apt update \
 && apt install -y --no-install-recommends openssl ffmpeg python vim ca-certificates curl git gnupg gosu \
 && gosu nobody true \
 && rm /var/lib/apt/lists/* -fR \
 && groupadd -r peertube \
 && useradd -r -g peertube -m peertube \
 && mkdir /app \
 && chown -R peertube:peertube /app

# Install PeerTube
WORKDIR /app
USER peertube

RUN VERSION=$(curl -s https://api.github.com/repos/chocobozzz/peertube/releases/latest | grep tag_name | cut -d '"' -f 4) \
  && git clone https://github.com/Chocobozzz/PeerTube.git . \
  && git checkout ${VERSION}

RUN yarn install --pure-lockfile \
    && npm run build -- $NPM_RUN_BUILD_OPTS \
    && rm -r ./node_modules ./client/node_modules \
    && yarn install --pure-lockfile --production \
    && yarn cache clean

USER root

RUN \
  cp support/docker/production/entrypoint.sh /usr/local/bin/entrypoint.sh \
  && mkdir /data /config \
  && chown -R peertube:peertube /data /config \
  && chmod 755 /usr/local/bin/entrypoint.sh

ENV NODE_ENV production
ENV NODE_CONFIG_DIR /config

VOLUME /data
VOLUME /config

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 9000 1935

CMD ["npm", "start"]
