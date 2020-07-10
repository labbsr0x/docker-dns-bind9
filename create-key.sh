#!/bin/bash
set -e

BIND_DATA_DIR=${DATA_DIR}/bind
ZONE="$1"

create_key() {
  create_key_dir
  
  cd ${BIND_DATA_DIR}/key
  dnssec-keygen -a HMAC-MD5 -b 512 -n HOST ${ZONE}
}

create_key_dir() {
  if [ ! -d ${BIND_DATA_DIR}/key ]; then
    mkdir ${BIND_DATA_DIR}/key
  fi
}

if [ -z "$ZONE" ] 
then
	echo "Set zone to create a key"
else
	echo "Create key to zone ${ZONE}"
  create_key
fi



