#!/bin/bash
ALL_YES=1;
usage() { echo "Usage: $0 [-n appname] [-y yes to all]" 1>&2; exit 1; }
confirm_action () {
  if [[ ALL_YES -eq 0 ]];then return 0;fi;
  read -p "${1}" -n 1 -r
  echo # empty line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
     return 1 # handle exits from shell or function but don't exit interactive shell
  fi
  return 0;
}

read_env_file(){
  ENV_FILE=$DIR/config/$INSTANCE_NAME.env
  if [[ ! -f "$ENV_FILE" ]]; then
      echo "Environment file $ENV_FILE not found"
      echo "Please provide a valid env file name"
      echo "Example : "
      echo "    $0         : will use the file config/default.env"
      echo "    $0 -n test : will use the file config/test.env"
      exit 0
  fi
  source $ENV_FILE
}

build_var(){
  DB_NAME=${INSTANCE_NAME}_db
  HMD_NAME=${INSTANCE_NAME}_hmd
  DOCKER_NETWORK=${DOCKER_NETWORK:-"www"}
  DATA_DIR=$DIR/data/${INSTANCE_NAME}
  BACKUP_PATH=$DIR/backup/${INSTANCE_NAME}
}

rm_containers(){
  echo "RM ${DB_NAME} and ${HMD_NAME}"
  sudo docker ps -a |grep --quiet ${DB_NAME}
  if [[ $? -eq 0 ]]; then
    sudo docker rm -vf ${DB_NAME}
  fi;
  sudo docker ps -a |grep --quiet ${HMD_NAME}
  if [[ $? -eq 0 ]]; then
    sudo docker rm -vf ${HMD_NAME}
  fi;
}

print_conf(){
  echo "-- CONFIGURATION :"
  echo "-----------------------------------------------------"
  echo "LDAP_DOCKER_INSTANCE_NAME=${LDAP_DOCKER_INSTANCE_NAME}"
  echo "-----------------------------------------------------"
}
