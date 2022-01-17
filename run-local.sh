#!/bin/bash
# @file run-local.sh
# @brief Translate Asciidoc file into RevealJS page and run in local webserver.
#
# @description The script translates an Asciidoc file intoa RevealJS page and runs it in local webserver using port 8888.
#
# ==== Arguments
#
# The script does not accept any parameters.
#
# ==== See also
#
# * link:https://docs.asciidoctor.org/reveal.js-converter/latest[Asciidoctor reveal.js Documentation]

CONTAINER_MOUNT_POINT="/documents"
TARGET_DIR="target/content"
SRC_DIR="content"

echo -e "$LOG_INFO Build reveal-js pages"
docker run --rm -it --volume "$PWD:/$CONTAINER_MOUNT_POINT" asciidoctor/docker-asciidoctor:latest \
  asciidoctor-revealjs -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2 "$SRC_DIR/index.adoc"

echo -e "$LOG_INFO Prepare target directory"
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

echo -e "$LOG_INFO Move files to target directory"
mv "$SRC_DIR/index.html" "$TARGET_DIR/index.html"
cp -a "$SRC_DIR/images" target/content

echo -e "$LOG_INFO Starting local webserver (node module)"
webserver 8888 "$TARGET_DIR"
