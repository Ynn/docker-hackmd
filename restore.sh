#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/util.sh
usage() { echo "Usage: $0 [-n appname] [-y yes to all]" 1>&2; exit 1; }
while getopts ":n:f:y" o; do
    case "${o}" in
        n)
          INSTANCE_NAME=${OPTARG}
          ;;
        f)
          FILE_NAME=${OPTARG}
          ;;
        y)
          ALL_YES=0
            ;;
        *)
            usage
            ;;
    esac
done

EXTENSION="tar.gz"
INSTANCE_NAME=${INSTANCE_NAME:-"default"}
read_env_file;
build_var;

if [[ -z $FILE_NAME ]]
then
  FILE_NAME=$(/bin/sh -c "(cd ${BACKUP_PATH} && ls -t ./*${INSTANCE_NAME}.${EXTENSION} | head -1)")
fi


confirm_action "Restore backup $FILE_NAME (y/n) ?"
if [[ $? -eq 0 ]]
then
  echo "RESTORE BACKUP --"
  sudo docker stop ${HMD_NAME}
  sudo rm -Rf ${DATA_DIR}
  sudo mkdir ${DATA_DIR}
  sudo tar -xvf ${BACKUP_PATH}/${FILE_NAME} -C ${DATA_DIR}
  sudo docker start ${HMD_NAME}
  #docker exec -i ${DB_NAME} /bin/sh -c "pg_restore -C -c ${FILE_NAME} "

  echo " --- done restore ...> $FILE_NAME ";
else
  echo "--- skip restore";
fi
