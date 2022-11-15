#!/bin/bash
# @file run.sh
# @brief Translate Asciidoc file into RevealJS page and run in local webserver.
#
# @description The script translates an Asciidoc file into a RevealJS page.
#
# | What                     | Port | Protocol |
# | ------------------------ | ---- | -------- |
# |  webserver (node module) | 7080 | http     |
#
# === Script Arguments
#
# The script does not accept any parameters.
#
# === See
#
# * link:https://docs.asciidoctor.org/reveal.js-converter/latest[Asciidoctor reveal.js Documentation]

MOUNT_POINT="/documents"
TARGET_DIR="target/content"
SRC_DIR="src/main"
DOCKER_IMAGE="local/website-tafelboy:dev"


echo -e "$LOG_INFO Build reveal-js pages"
docker run --rm -it --volume "$(pwd):/$MOUNT_POINT" asciidoctor/docker-asciidoctor:latest \
  asciidoctor-revealjs -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2 "$SRC_DIR/index.adoc"

echo -e "$LOG_INFO Prepare target directory"
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

echo -e "$LOG_INFO Move files to target directory"
mv "$SRC_DIR/index.html" "$TARGET_DIR/index.html"
#cp -a "$SRC_DIR/images" "$TARGET_DIR"

echo -e "$LOG_INFO Remove old versions of $DOCKER_IMAGE"
docker image rm "$DOCKER_IMAGE"

echo -e "$LOG_INFO Build Docker image $DOCKER_IMAGE"
docker build -t "$DOCKER_IMAGE" .

echo -e "$LOG_INFO Run Docker image"
docker run --rm mwendler/figlet "    7888"
docker run --rm -p 7888:80 "$DOCKER_IMAGE"
