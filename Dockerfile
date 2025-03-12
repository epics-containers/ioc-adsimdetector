ARG IMAGE_EXT

ARG BASE=7.0.8ec2
ARG REGISTRY=ghcr.io/epics-containers
ARG RUNTIME=${REGISTRY}/epics-base${IMAGE_EXT}-runtime:${BASE}
ARG DEVELOPER=${REGISTRY}/epics-base${IMAGE_EXT}-developer:${BASE}

##### build stage ##############################################################
FROM  ${DEVELOPER} AS developer

# TODO this will go in epics-base
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y ansible-core && \
    rm -rf /var/lib/apt/lists/*

# The devcontainer mounts the project root to /epics/generic-source
# Using the same location here makes devcontainer/runtime differences transparent.
ENV SOURCE_FOLDER=/epics/generic-source
# connect ioc source folder to its know location
RUN ln -s ${SOURCE_FOLDER}/ioc ${IOC}

# Get the current version of ibek
COPY requirements.txt requirements.txt
RUN pip install --upgrade -r requirements.txt

WORKDIR ${SOURCE_FOLDER}/ibek-support

COPY ibek-support/_global/ _global
COPY ibek-support/_ansible _ansible
RUN ln -s _ansible/ansible.sh .

COPY ibek-support/iocStats/ iocStats
RUN ./ansible.sh iocStats

COPY ibek-support/asyn/ asyn
RUN ./ansible.sh asyn

COPY ibek-support/busy/ busy
RUN ./ansible.sh busy

COPY ibek-support/sscan/ sscan
RUN ./ansible.sh sscan

COPY ibek-support/calc/ calc
RUN ./ansible.sh calc

COPY ibek-support/ADCore/ ADCore
RUN ./ansible.sh ADCore

COPY ibek-support/ffmpegServer/ ffmpegServer
RUN ./ansible.sh ffmpegServer

COPY ibek-support/ADSimDetector/ ADSimDetector
RUN ./ansible.sh ADSimDetector

COPY ibek-support/autosave/ autosave
RUN ./ansible.sh autosave

# get the ioc source and build it
COPY ioc ${SOURCE_FOLDER}/ioc
RUN cd ${IOC} && ./ansible_ioc.sh && make

# install runtime proxy for non-native builds
# TODO: get ansible to do this bit too
RUN bash ${IOC}/install_proxy.sh

##### runtime preparation stage ################################################
FROM developer AS runtime_prep

# get the products from the build stage and reduce to runtime assets only
RUN ibek ioc extract-runtime-assets /assets

##### runtime stage ############################################################
FROM ${RUNTIME} AS runtime

# get runtime assets from the preparation stage
COPY --from=runtime_prep /assets /

# install runtime system dependencies, collected from install.sh scripts
RUN ibek support apt-install-runtime-packages --skip-non-native

CMD ["bash", "-c", "${IOC}/start.sh"]

##### stage that fully configures the example IOC ##################

FROM runtime as demo

COPY services/bl01t-ea-ioc-02/config /epics/ioc/config

ENV IOC_NAME=BL01T-EA-TST-02
