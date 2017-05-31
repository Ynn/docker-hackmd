#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/util.sh
usage() { echo "Usage: $0 [-n appname] [-y yes to all]" 1>&2; exit 1; }
while getopts ":n:y" o; do
    case "${o}" in
        n)
          INSTANCE_NAME=${OPTARG}
          ;;
        y)
          ALL_YES=0
            ;;
        *)
            usage
            ;;
    esac
done



INSTANCE_NAME=${INSTANCE_NAME:-"default"}
read_env_file;
build_var;
echo "Check configuration :"
print_conf;

sudo docker ps -a |grep --quiet ${LDAP_DOCKER_INSTANCE_NAME}
if [[ ! $? -eq 0 ]]; then
  echo "ERROR : LDAP docker instance \"${LDAP_DOCKER_INSTANCE_NAME}\" is not running."
  echo 'Please make sure LDAP is running before running this script.'
  exit 0;
fi;

confirm_action "Use this configuration (make sure the ldap service is running)? (y/n)"
if [[ ! $? -eq 0 ]]; then
  echo "--- abort";
  exit 1;
fi

sudo docker network ls |grep --quiet ${DOCKER_NETWORK}
if [[ ! $? -eq 0 ]]; then
  sudo docker network create  ${DOCKER_NETWORK};
fi;

# Remove all containers :
rm_containers;

# (cd $DIR && \
# 	sudo docker run \
#   --restart unless-stopped\
# 	--network=${DOCKER_NETWORK} \
# 	--name ${DB_NAME}\
# 	--hostname ${DB_NAME}\
# 	--env POSTGRES_USER=${POSTGRES_USER} \
# 	--env POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
# 	--env POSTGRES_DB=${POSTGRES_DB} \
#   -v $DIR/backup/${INSTANCE_NAME}:/backup \
# 	--detach postgres\
# )

(cd $DIR && \
	sudo docker run \
  --restart unless-stopped\
	--network=${DOCKER_NETWORK} \
	--name ${HMD_NAME}\
	--hostname ${HMD_NAME}\
  --env  HMD_EMAIL=false \
  --env  HMD_ALLOW_EMAIL_REGISTER=false \
  --env  HMD_IMAGE_UPLOAD_TYPE=filesystem \
  --env  HMD_ALLOW_ANONYMOUS=false \
  --env  HMD_LDAP_URL=ldap://ldap-host \
  --env  HMD_LDAP_BINDDN="${HMD_LDAP_BINDDN}" \
  --env  HMD_LDAP_BINDCREDENTIALS="${HMD_LDAP_BINDCREDENTIALS}" \
  --env  HMD_LDAP_SEARCHBASE="${HMD_LDAP_SEARCHBASE}" \
  --env  HMD_LDAP_SEARCHFILTER="${HMD_LDAP_SEARCHFILTER}" \
  --env  VIRTUAL_HOST="${VIRTUAL_HOST}" \
  --env  VIRTUAL_PORT=3000 \
  --link ${LDAP_DOCKER_INSTANCE_NAME}:ldap-host \
  -v ${DATA_DIR}/uploads:/hackmd/public/uploads \
  -v ${DATA_DIR}/db:/hackmd/db \
  -p 3000:3000 \
	--detach nnynn/hackmd:latest\
)
# --link ${DB_NAME}:hackmdPostgres \
# --env POSTGRES_USER=${POSTGRES_USER} \
# --env POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \

echo "HMD is installed, please note that HMD can be long to start"
