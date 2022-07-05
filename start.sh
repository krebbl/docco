#!/bin/sh

set -o allexport
source /home/docco/docco.env
set +o allexport

mkdir -p $DOCCO_GIT_DIR
mkdir -p $DOCCO_APPS_DIR

# Checking permissions and fixing SGID bit in repos folder
# More info: https://github.com/jkarlosb/git-server-docker/issues/1

chown -R docco:docco $DOCCO_APPS_DIR
chown -R docco:docco $DOCCO_GIT_DIR
chmod -R ug+rwX $DOCCO_GIT_DIR
# chmod -R ug+rwX $DOCCO_GIT_DIR
# find $DOCCO_GIT_DIR -type d -exec chmod g+s '{}' +

# -D flag avoids executing sshd as a daemon
/usr/sbin/sshd -D
