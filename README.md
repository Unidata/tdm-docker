- [Unidata TDM Docker](#h-A4F8A5F1)
  - [Introduction](#h-A4FB9801)
  - [Versions](#h-59413645)
  - [Prerequisites](#h-4192CCA6)
  - [Installation](#h-2F4E806F)
  - [Usage](#h-0612419E)
    - [Docker compose](#h-1C0CB7E8)
      - [Running the TDM](#h-46CFD2DE)
      - [Stopping the TDM](#h-365B4A9F)
      - [Delete TDM Container](#h-96B64C5E)
    - [Upgrading](#h-73D8E285)
    - [Check What is Running](#h-E74AFAFF)
      - [docker ps](#h-E81E27D2)
  - [Configuration](#h-BA871A11)
    - [Docker Compose](#h-9BD50914)
    - [Configurable TDM UID and GID](#h-1CB62389)
    - [TDM Password and Coordination with the TDS](#h-7A6A748D)
  - [Citation](#h-0BAA13E6)
  - [Support](#h-7D1176D3)



<a id="h-A4F8A5F1"></a>

# Unidata TDM Docker

Dockerized [TDM](https://docs.unidata.ucar.edu/tds/current/userguide/tdm_ref.html).


<a id="h-A4FB9801"></a>

## Introduction

This repository contains files necessary to build and run a TDM Docker container which runs in conjunction with the THREDDS Docker container to provide indexes for GRIB featureCollections. The container can run on a different VM from THREDDS provided it has access to the same data directory THREDDS has access to via an NFS mount, for example. The Unidata TDM Docker images associated with this repository are [available on DockerHub](https://hub.docker.com/r/unidata/tdm-docker/).


<a id="h-59413645"></a>

## Versions

See tags listed [on dockerhub](https://hub.docker.com/r/unidata/tdm-docker/tags).


<a id="h-4192CCA6"></a>

## Prerequisites

Before you begin using this Docker container project, make sure your system has Docker installed. Docker Compose is optional but recommended.


<a id="h-2F4E806F"></a>

## Installation

You can either pull the image from DockerHub with:

```sh
docker pull unidata/tdm-docker:<version>
```

Or you can build it yourself with:

1.  ****Clone the repository****: `git clone https://github.com/Unidata/tdm-docker.git`
2.  ****Navigate to the project directory****: `cd tdm-docker`
3.  ****Build the Docker image****: `docker build -t tdm-docker:<version> .`


<a id="h-0612419E"></a>

## Usage


<a id="h-1C0CB7E8"></a>

### Docker compose

To run the TDM Docker container, beyond a basic Docker setup, we recommend installing [docker-compose](https://docs.docker.com/compose/). `docker-compose` serves two purposes:

1.  Reduce headaches involving unwieldy `docker` command lines where you are running `docker` with multiple volume mounts and port forwards. In situations like these, `docker` commands become difficult to issue and read. Instead, the lengthy `docker` command is captured in a `docker-compose.yml` that is easy to read, maintain, and can be committed to version control.

2.  Coordinate the running of two or more containers. This can be useful for taking into account the same volume mountings, for example.

However, `docker-compose` use is not mandatory. There is an example [docker-compose.yml](https://github.com/Unidata/tdm-docker/blob/master/docker-compose.yml) in this repository.


<a id="h-46CFD2DE"></a>

#### Running the TDM

Once you have completed your setup you can run the container with:

```sh
docker-compose up -d tdm
```

The output of such command should be something like:

```
Creating tdm
```


<a id="h-365B4A9F"></a>

#### Stopping the TDM

To stop this container:

```sh
docker-compose stop tdm
```


<a id="h-96B64C5E"></a>

#### Delete TDM Container

To clean the slate and remove the container (not the image, the container):

```sh
docker-compose rm -f tdm
```


<a id="h-73D8E285"></a>

### Upgrading

Upgrading to a newer version of the container is easy. Simply stop the container via `docker` or `docker-compose`, followed by

```sh
docker pull unidata/tdm-docker:<version>
```

and restart the container. Refer to the new version from the command line or in the `docker-compose.yml`.


<a id="h-E74AFAFF"></a>

### Check What is Running


<a id="h-E81E27D2"></a>

#### docker ps

```sh
docker ps
```

which should give you output that looks something like this:

```
CONTAINER ID   IMAGE                       COMMAND                  CREATED        STATUS       PORTS                                   NAMES
d4a1424d9375   unidata/tdm-docker:4.5   "/entrypoint.sh tdm.…"   5 weeks ago    Up 5 weeks                                           tdm
```


<a id="h-BA871A11"></a>

## Configuration


<a id="h-9BD50914"></a>

### Docker Compose

To run the TDM Docker container, beyond a basic Docker setup, we recommend installing [docker-compose](https://docs.docker.com/compose/). We will assume you have knowledge on how to [configure a TDS](https://docs.unidata.ucar.edu/tds/current/userguide/basic_config_catalog.html).

```yaml
version: '3'

services:
  tdm:
    image: unidata/tdm-docker:5.4
    container_name: tdm
    volumes:
      - /path/to/your/thredds/directory:/usr/local/tomcat/content/thredds
      - /path/to/your/data/directory1:/path/to/your/data/directory1
    env_file:
      - "compose${THREDDS_COMPOSE_ENV_LOCAL}.env"
```

In the `docker-compose.yml` file, `volumes` mapping section, you will point the TDM to the [TDS content root directory](https://github.com/Unidata/thredds-docker#thredds) and the `/data` directory corresponding to the `DataRoots` element in `threddsConfig.xml`. E.g.,

```yaml
volumes:
    # data directory
    - /data/:/data/
    #  TDS content root directory
    - ~/tdsconfig/:/usr/local/tomcat/content/thredds/
    - /logs/tdm/:/usr/local/tomcat/content/tdm/logs
```

Also note the `/data` directory will be the same directory the TDS container will be pointing to.

Because you will most likely run this container in conjunction with the `thredds-docker` container, see the `thredds-docker` project [README](https://github.com/Unidata/thredds-docker) for additional parameterization via the `compose.env` file. Pay special attention to the `TDS_HOST` environment variable which will tell the TDM where the TDS lives so that it can communicate with it. See the section below on [coordinating with the TDS](#h-7A6A748D).


<a id="h-1CB62389"></a>

### Configurable TDM UID and GID

[See parent unidata/tomcat container](https://github.com/Unidata/tomcat-docker#configurable-tomcat-uid-and-gid).

Set the UID/GID of the TDM user via the `compose.env` file. If not set, the default UID/GID is `1000/1000`.


<a id="h-7A6A748D"></a>

### TDM Password and Coordination with the TDS

The TDM will notify the TDS of data changes via an HTTPS port `8443` triggering mechanism. It is important the TDM password (`TDM_PW` environment variable) defined in the [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) file corresponds to the SHA **digested** password in the [tomcat-users.xml](https://github.com/Unidata/thredds-docker/blob/master/files/tomcat-users.xml) file. [See the parent Tomcat container](https://hub.docker.com/r/unidata/tomcat-docker/) for how to create a SHA digested password. Also, because this mechanism works via port `8443`, you will have to get your HTTPS certificates in place. Again [see the parent Tomcat container](https://hub.docker.com/r/unidata/tomcat-docker/) on how to install certificates, self-signed or otherwise.

Not having the Tomcat `tdm` user password and digested password in sync can be a big source of frustration. One way to diagnose this problem is to look at the TDM logs and `grep` for `trigger`. You will find something like:

```sh
fc.NAM-CONUS_80km.log:2016-11-02T16:09:54.305 +0000 WARN  - FAIL send trigger to https://tds.scigw.unidata.ucar.edu/thredds/admin/collection/trigger?trigger=never&collection=NAM-CONUS_80km status = 401
```

Enter the trigger URL in your browser:

```sh
https://tds.scigw.unidata.ucar.edu/thredds/admin/collection/trigger?trigger=never&collection=NAM-CONUS_80km
```

At this point the browser will prompt you for a `tdm` login and password you defined in the `docker-compose.yml`. If the triggering mechanism is successful, you see a `TRIGGER SENT` message. Otherwise, make sure your HTTPS certificate is present, and ensure the `tdm` password in the `docker-compose.yml`, and digested password in the `tomcat-users.xml` are in sync.


<a id="h-0BAA13E6"></a>

## Citation

In order to cite this project, please simply make use of the Unidata THREDDS Data Server DOI: https://doi.org/10.5065/D6N014KG <https://doi.org/10.5065/D6N014KG>


<a id="h-7D1176D3"></a>

## Support

If you have a question or would like support for this TDM Docker container, consider [submitting a GitHub issue](https://github.com/Unidata/tdm-docker/issues). Alternatively, you may wish to start a discussion on the THREDDS Community mailing list: [thredds@unidata.ucar.edu](mailto:thredds@unidata.ucar.edu).

For general TDS questions, please see the [THREDDS support page](https://www.unidata.ucar.edu/software/tds/#help).
