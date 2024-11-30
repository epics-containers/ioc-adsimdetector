#!/bin/bash

# A launcher for the ioc-adsimdetector-demo IOC

# prefer docker but use podman if USE_PODMAN is set
if docker version &> /dev/null && [[ -z $USE_PODMAN ]]
    then docker=docker
    else docker=podman
fi
echo "Using $docker to launch the IOC"

ca="-p 127.0.0.1:5064:5064/udp -p 127.0.0.1:5064-5065:5064-5065"
pva="-p 127.0.0.1:5076:5076/udp -p 127.0.0.1:5075:5075"
args="--rm -it"
image="ghcr.io/epics-containers/ioc-adsimdetector-demo:2024.11.1"
$docker run $args $ca $pva $image
