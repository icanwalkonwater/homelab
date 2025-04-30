#!/bin/sh
# Wrapper script adapter from lazymc example

# Server JAR file
SERVER_JAR=lwjgl3ify-forgePatches.jar

# Accept eula
if [ "$EULA" = "true" ]; then
  sed -n -e '/^eula=/!p' -e '$aeula=true' -i eula.txt
else
  echo '[lucasfilm] You forgot to accept the EULA !'
fi

# Patch server.properties
if [ -n "$MOTD"]; then
  echo '[lucasfilm] Patching MOTD'
  sed -n -e '/^motd=/!p' -e "\$amotd=$MOTD" -i server.properties
fi
if [ -n "$DIFFICULTY" ]; then
  echo '[lucasfilm] Patching difficulty'
  sed -n -e '/^difficulty=/!p' -e "\$adifficulty=$DIFFICULTY" -i server.properties
fi
if [ -n "$VIEW_DISTANCE" ]; then
  echo '[lucasfilm] Patching view distance'
  sed -n -e '/^view-distance=/!p' -e "\$aview-distance=$VIEW_DISTANCE" -i server.properties
fi
if [ -n "$SEED" ]; then
  echo '[lucasfilm] Patching seed'
  sed -n -e '/^level-seed=/!p' -e "\$alevel-seed=$SEED" -i server.properties
fi

# Force enable RCON
echo '[lucasfilm] Patching RCON settings'
sed -n -e '/^enable-rcon=/!p' -e '$aenable-rcon=true' -i server.properties
sed -n -e '/^rcon.port=/!p' -e '$arcon.port=25575' -i server.properties
sed -n -e '/^rcon.password=/!p' -e '$arcon.password=uwu' -i server.properties

# Setup java variables
INIT_MEMORY=${INIT_MEMORY:-1G}
MAX_MEMORY=${MAX_MEMORY:-1G}

# Trap SIGTERM, forward it to server process ID
trap 'kill -TERM $PID' TERM INT

# Start server
java -Xms$INIT_MEMORY -Xmx$MAX_MEMORY @java9args.txt -jar $SERVER_JAR --nogui &

# Remember server process ID, wait for it to quit, then reset the trap
PID=$!
wait $PID
trap - TERM INT
wait $PID
