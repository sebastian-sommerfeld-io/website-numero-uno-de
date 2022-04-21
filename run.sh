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
# ==== Arguments
#
# The script does not accept any parameters.
#
# ==== See also
#
# * link:https://docs.asciidoctor.org/reveal.js-converter/latest[Asciidoctor reveal.js Documentation]

MOUNT_POINT="/documents"
TARGET_DIR="target/content"
SRC_DIR="src/main"


echo -e "$LOG_INFO Download latest linter definitions"
linterDefinitions=(
  '.ls-lint.yml'
  '.yamllint'
  '.folderslintrc'
)
for file in "${linterDefinitions[@]}"; do
  rm "$file"
  curl -sL "https://raw.githubusercontent.com/sebastian-sommerfeld-io/infrastructure/main/resources/common-assets/linters/$file" -o "$file"
  git add "$file"
done

echo -e "$LOG_INFO ------------------------------------------------------------------------"
echo -e "$LOG_INFO Run linter containers"
docker run -it --rm --volume "$(pwd):/data" --workdir "/data" cytopia/yamllint:latest .
docker run -it --rm --volume "$(pwd):/data" --workdir "/data" koalaman/shellcheck:latest ./*.sh
#docker run -i  --rm hadolint/hadolint < Dockerfile
docker run -it --rm --volume "$(pwd):/data" --workdir "/data" lslintorg/ls-lint:1.11.0
docker run -i  --rm --volume "$(pwd):$(pwd)" --workdir "$(pwd)" pegasus/folderslint:latest folderslint .
echo -e "$LOG_INFO ------------------------------------------------------------------------"

echo -e "$LOG_INFO Build reveal-js pages"
docker run --rm -it --volume "$(pwd):/$MOUNT_POINT" asciidoctor/docker-asciidoctor:latest \
  asciidoctor-revealjs -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2 "$SRC_DIR/index.adoc"

echo -e "$LOG_INFO Prepare target directory"
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

echo -e "$LOG_INFO Move files to target directory"
mv "$SRC_DIR/index.html" "$TARGET_DIR/index.html"
/cp -a "$SRC_DIR/images" "$TARGET_DIR"

echo -e "$LOG_INFO Starting local webserver (node module)"
webserver 7080 "$TARGET_DIR"
