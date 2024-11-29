#!/bin/bash

# A launcher for the phoebus container that allows X11 forwarding

thisdir=$(realpath $(dirname $0))
workspace=$(realpath ${thisdir}/..)

settings="
-resource ${workspace}/opi/auto-generated/index.bob
-settings ${workspace}/opi/settings.ini
"

if which phoebus.sh &>/dev/null ; then
    echo "Using phoebus.sh from PATH"
    set -x
    phoebus.sh ${settings} "${@}"

elif module load phoebus 2>/dev/null; then
    echo "Using phoebus module"
    set -x
    phoebus.sh ${settings} "${@}"

else
    echo "No phoebus module found, using a container"

    # podman vs docker differences.
    if podman version &> /dev/null && [[ -z $USE_DOCKER ]] ; then
        USER_ID=0; USER_GID=0
        docker=podman
    else
        USER_ID=$(id -u); USER_GID=$(id -g)
        docker=docker
    fi

    if [[ $(docker --version 2>/dev/null) == *Docker* ]]; then
        docker=docker
    else
        docker=podman
        args="--security-opt=label=type:container_runtime_t"
    fi

    x11="
    -e DISPLAY
    -v $XAUTH:$XAUTH
    -e XAUTHORITY=$XAUTH
    --net host
    "

    args=${args}"
    -it --security-opt=label=none
    "

    # mount in your own home dir in same folder for access to external files
    mounts="
    -v=/tmp:/tmp
    -v=${workspace}:/workspace
    "

    # settings for p47
    settings="
    -resource /workspace/opi/p47-beamline.opi
    -settings /workspace/opi/settings.ini
    "

    set -x
    $docker run ${mounts} ${args} ${x11} ghcr.io/epics-containers/ec-phoebus:latest ${settings} "${@}"

fi

