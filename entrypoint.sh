#!/bin/sh

USER=influxdb
OLD_UID="$( id -u ${USER} )"
OLD_GID="$( id -g ${USER} )"
CHANGED=""

if [ -z "${USER_UID}" ]; then
  USER_UID="${OLD_UID}"
fi

if [ -z "${USER_GID}" ]; then
  USER_GID="${OLD_GID}"
fi

## Change GID for USER?
if [ -n "${USER_GID}" ] && [ "${USER_GID}" != "${OLD_GID}" ]; then
    sed -i -e "s/^${USER}:\([^:]*\):[0-9]*/${USER}:\1:${USER_GID}/" /etc/group
    sed -i -e "s/^${USER}:\([^:]*\):\([0-9]*\):[0-9]*/${USER}:\1:\2:${USER_GID}/" /etc/passwd
    CHANGED="1"
fi

## Change UID for USER?
if [ -n "${USER_UID}" ] && [ "${USER_UID}" != "${OLD_UID}" ]; then
    sed -i -e "s/^${USER}:\([^:]*\):[0-9]*:\([0-9]*\)/${USER}:\1:${USER_UID}:\2/" /etc/passwd
    CHANGED="1"
fi

## Change ownership of user's files
if [ ! -z "$CHANGED" ]; then
    find / \
        \( -uid "${OLD_UID}" -o -gid "${OLD_GID}" \) -not \
        \( -path /proc\* -o -path /tmp\* \) \
        -exec chown "${USER_UID}:${USER_GID}" {} \;
fi

## Run the entrypoint as the desired user
exec chroot --userspec=${USER_UID} / /run.sh "${@}"
