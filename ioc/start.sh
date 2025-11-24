#!/bin/bash

# log commands and stop on errors
set -xe

# wrap this script in stdio-expose if running in Kubernetes
# this allows the IOC to expose its console on a Unix socket
if [[ -n ${KUBERNETES_PORT} && -z ${STDIO_EXPOSED} ]]; then
    STDIO_EXPOSED=YES exec stdio-expose ${IOC}/start.sh
    exit 0
fi

# error reporting **************************************************************

function ibek_error {
    local error_code=$?
    local error_line=$BASH_LINENO
    local error_command=$BASH_COMMAND
    echo "Error on line $error_line: $error_command (exit code: $error_code)"
    echo "$1"

    # Wait for a bit so the container does not exit and restart continually
    sleep 120
    exit 1
}

trap ibek_error ERR

# environment setup ************************************************************

cd ${IOC}

CONFIG_DIR=${IOC}/config
RUNTIME_DIR=${EPICS_ROOT}/runtime

# add module paths to environment for use in ioc startup script
if [[ -f ${SUPPORT}/configure/RELEASE.shell ]]; then
    source ${SUPPORT}/configure/RELEASE.shell
fi

mkdir -p ${RUNTIME_DIR}

# check for an override start.sh script ****************************************

if [ -f ${CONFIG_DIR}/start.sh ]; then
    exec bash ${CONFIG_DIR}/start.sh

# copy hand coded files to runtime folder **************************************

for f in ioc.db ioc.subst st.cmd; do
    if [ -f ${CONFIG_DIR}/${f} ]; then
        cp ${CONFIG_DIR}/${f} ${RUNTIME_DIR}/
    fi
done

# copy any streamDevice protocol files to runtime folder ***********************

if [[ -d /epics/support/configure/protocol ]] ; then
    rm -fr ${RUNTIME_DIR}/protocol
    cp -r /epics/support/configure/protocol  ${RUNTIME_DIR}
fi

# generate EPICS runtime assets ************************************************

ibek runtime generate2 ${CONFIG_DIR}
ibek runtime generate-autosave

# build expanded database using msi
if [ -f ${RUNTIME_DIR}/ioc.subst ]; then
    includes=$(for i in ${SUPPORT}/*/db; do echo -n "-I $i "; done)
    bash -c "msi -o${RUNTIME_DIR}/ioc.db ${includes} -I${RUNTIME_DIR}
             -S${RUNTIME_DIR}/ioc.subst"
fi

# Launch the IOC ***************************************************************

${IOC}/bin/linux-x86_64/ioc ${RUNTIME_DIR}/st.cmd

