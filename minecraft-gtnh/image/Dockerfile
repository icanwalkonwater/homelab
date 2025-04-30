FROM eclipse-temurin:21.0.7_6-jre-alpine-3.21

ARG LAZYMC_VERSION=v0.2.11
ARG RCONCLI_VERSION=1.7.0
ARG GTNH_VERSION=2.7.4
ARG GTNH_VARIANT=Java_17-21

# Setup user
RUN adduser -D -H minecraft

# Download lazymc binary
RUN mkdir -p /usr/local/bin &&\
    wget https://github.com/timvisee/lazymc/releases/download/${LAZYMC_VERSION}/lazymc-${LAZYMC_VERSION}-linux-x64-static -O /usr/local/bin/lazymc &&\
    chmod +x /usr/local/bin/lazymc

# Download rcon-cli binary
RUN mkdir -p /usr/local/bin &&\
    wget https://github.com/itzg/rcon-cli/releases/download/${RCONCLI_VERSION}/rcon-cli_${RCONCLI_VERSION}_linux_amd64.tar.gz -O /tmp/rcon-cli.tar.gz &&\
    tar -xvf /tmp/rcon-cli.tar.gz -C /usr/local/bin rcon-cli &&\
    chmod +x /usr/local/bin/rcon-cli

# Setup /minecraft directory
# - Download & extract pack archive
# - Prepare directories susceptible to being mounted (/World, /backups)
# - Set permissions
RUN mkdir /minecraft &&\
    wget https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_${GTNH_VERSION}_Server_${GTNH_VARIANT}.zip -O /minecraft/pack.zip &&\
    unzip /minecraft/pack.zip -d /minecraft &&\
    rm /minecraft/pack.zip  &&\
    mkdir -p /minecraft/World /minecraft/backups &&\
    chown -R minecraft:minecraft /minecraft

# Patches for the pack
RUN sed s/B:chunk_claiming=false/B:chunk_claiming=true/ -i /minecraft/serverutilities/serverutilities.cfg

# Add our config & wrappers
COPY --chown=minecraft:minecraft --chmod=644 lazymc.toml /minecraft
COPY --chown=minecraft:minecraft --chmod=755 start-server.sh /minecraft

# Check lazymc config
RUN lazymc config test --config /minecraft/lazymc.toml

WORKDIR /minecraft
USER minecraft
CMD ["lazymc", "start"]
