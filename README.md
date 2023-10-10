ADSimDetector Generic IOC for epics-containers
==============================================

Creates a generic IOC for ADSimDetector using GitHub Actions and
IOC Builder for EPICS and Kubernetes (ibek).

The Generic IOC built by CI is published to
[Github Packages](https://github.com/orgs/epics-containers/packages?repo_name=ioc-adsimdetector).

The registry provides a runtime
image for deploying to production and a dev image for testing,
debugging and developing new features. epics-containers implements
tools to launch IOCs in a Kubernetes cluster. But any container
runtime can be used to launch an IOC instance by mounting configuration
files into the container.

## Launching an IOC instance

The Generic IOC can be launched as an IOC instance. To do this a
container runtime should load the above runtime image and mount
instance configuration files into the folder `/epics/ioc/config`.

Options for the configuration files are:-

- ioc.yaml:
  - If the config folder contains an ioc.yaml file we invoke the ibek tool to
    generate the startup script and database. Then launch with the generated
    startup script.

- st.cmd + ioc.subst:
  - If the config folder contains a st.cmd script and a ioc.subst file then
    optionally generate ioc.db from the ioc.subst file and use the st.cmd script
    as the IOC startup script. Note that the expanded database file will
    be generated in /tmp/ioc.db

 - start.sh:
   - If the config folder contains a start.sh script it will be executed.
     This allows the instance implementer to provide a completely custom
     startup script.

- no mount:
  -  If the config folder is empty then this Generic IOC will launch the
     example IOC instance

## Related projects

- [ibek](https://github.com/epics-containers/ibek) builds generic IOCs and
IOC instances.
- [ibek-support](https://github.com/epics-containers/ibek-support) tells ibek
how each EPICS support module is built.
- [epics containers documentation](https://epics-containers.github.io/)
explanations and tutorials for epics-containers.
- [epics-base](https://github.com/epics-containers/epics-base) the EPICS base
container image upon which all Generic IOCs are built.
- [epics-containers-cli](https://github.com/epics-containers-cli) a command
  line tool to assist with building and deploying epics-containers into
  Kubernetes.

