#!/bin/bash
# @file deploy.sh
# @brief Deploy generated HTML to webspace.
#
# @description The script deploys the generated HTML via FTP to the webspace. Use ``run.sh`` to generate HTML first.
#
# IMPORTANT: Run only in Vagrantbox ``pegasus``. Other machines cannot provide the necessary docker image.
#
# ==== Arguments
#
# The script does not accept any parameters.


case $HOSTNAME in
("pegasus") echo -e "$LOG_INFO Script running on expected machine $HOSTNAME";;
(*)         echo -e "$LOG_ERROR SCRIPT NOT RUNNING ON EXPECTED MACHINE !!!" && echo -e "$LOG_ERROR Exit" && exit;;
esac


FTP_HOST="w00f8074.kasserver.com"
FTP_USER_FILE="resources/.secrets/ftp.user"
FTP_PASS_FILE="resources/.secrets/ftp.pass"
CONTENT_DIR="target/content"


echo -e "$LOG_INFO Read FTP user and password from $FTP_USER_FILE and $FTP_PASS_FILE"
FTP_USER=$(cat "$FTP_USER_FILE")
FTP_PASS=$(cat "$FTP_PASS_FILE")


if [[ ! -d "$CONTENT_DIR" ]]
then
  echo -e "$LOG_ERROR Directory '$CONTENT_DIR' missing -> No files to upload"
  echo -e "$LOG_ERROR exit"
  exit 0
fi


echo -e "$LOG_INFO Deploy files to webspace via FTP"
(
  cd "$CONTENT_DIR" || exit
  # shellcheck disable=SC2035
  docker run -it --rm --volume "$(pwd):$(pwd)" --workdir "$(pwd)" pegasus/ftp-client:latest ncftpput -R -v -u "$FTP_USER" -p "$FTP_PASS" "$FTP_HOST" / *
)
