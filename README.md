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

See tags listed [on DockerHub](https://hub.docker.com/r/unidata/tdm-docker/tags).


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

    Creating tdm


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

    CONTAINER ID   IMAGE                       COMMAND                  CREATED        STATUS       PORTS                                   NAMES
    d4a1424d9375   unidata/tdm-docker:5.10   "/entrypoint.sh tdm.…"   5 weeks ago    Up 5 weeks                                           tdm


<a id="h-BA871A11"></a>

## Configuration


<a id="h-9BD50914"></a>

### Docker Compose

To run the TDM Docker container, beyond a basic Docker setup, we recommend installing [docker-compose](https://docs.docker.com/compose/). We will assume you have knowledge on how to [configure a TDS](https://docs.unidata.ucar.edu/tds/current/userguide/basic_config_catalog.html).

```yaml
version: '3'

services:
  tdm:
    image: unidata/tdm-docker:5.10-SNAPSHOT
    container_name: tdm
    volumes:
      - /path/to/your/thredds/directory:/usr/local/tomcat/content/thredds
      - /path/to/your/data/directory1:/path/to/your/data/directory1:ro
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

The container is configured with these environment variables:

| Setting              | Environment variable                                | Example/default             |
|-------------------- |--------------------------------------------------- |--------------------------- |
| TDS content root     | TDS<sub>CONTENT</sub><sub>ROOT</sub><sub>PATH</sub> | /usr/local/tomcat/content   |
| TDS trigger password | TDM<sub>PW</sub>                                    | No default; required        |
| TDS base URL         | TDS<sub>HOST</sub>                                  | <https://tds.example.test/> |
| Maximum Java heap    | TDM<sub>XMX</sub><sub>SIZE</sub>                    | 6G                          |
| Minimum Java heap    | TDM<sub>XMS</sub><sub>SIZE</sub>                    | 1G                          |
| Runtime user ID      | TDM<sub>USER</sub><sub>ID</sub>                     | 1000                        |
| Runtime group ID     | TDM<sub>GROUP</sub><sub>ID</sub>                    | 1000                        |

Do not put a real password in the tracked `compose.env` template. Copy it to the ignored `compose.local.env`, set `TDM_PW` there, and select it when starting Compose:

```sh
cp compose.env compose.local.env
chmod 600 compose.local.env
THREDDS_COMPOSE_ENV_LOCAL=.local docker compose up -d tdm
```

The `env_file` entry in `docker-compose.yml` expands this variable as `compose${THREDDS_COMPOSE_ENV_LOCAL}.env`; setting it to `.local` therefore selects `compose.local.env`. Leaving it unset selects the tracked `compose.env` template.

The TDM receives this password through its environment and passes it to the Java process as a command-line argument. Limit access to the Docker host and its process/container metadata accordingly.


<a id="h-1CB62389"></a>

### Configurable TDM UID and GID

The TDM process runs under the numeric UID/GID specified by `TDM_USER_ID` and `TDM_GROUP_ID`, which default to `1000/1000`. At startup, the container creates `tdm` user or group entries only when those numeric IDs do not already exist. If the IDs already belong to named identities in the image, those identities are used without modification.

Only the TDM log and Java Preferences directories are made writable by the runtime UID/GID. The JAR, scripts, and logging configuration remain root-owned.


<a id="h-7A6A748D"></a>

### TDM Password and Coordination with the TDS

The TDM notifies the TDS through its protected collection-trigger endpoint. Create a Tomcat user named `tdm` with only the `tdsTrigger` role. The username is currently fixed by `tdm.sh`.

For example, add the following role and user to the `tomcat-users.xml` mounted by the TDS container:

```xml
<tomcat-users>
  <role rolename="tdsTrigger"/>
  <user username="tdm"
        password="DIGESTED_PASSWORD"
        roles="tdsTrigger"/>
</tomcat-users>
```

Generate `DIGESTED_PASSWORD` using the SHA-512 procedure in the [Tomcat Docker documentation](https://github.com/Unidata/tomcat-docker#digested-passwords). Set `TDM_PW` to the original cleartext password used to produce that digest, not to the digest itself. Mount `tomcat-users.xml` read-only in the TDS container and restart the TDS after changing it.

Set the `TDS_HOST` to the TDS base HTTPS URL reachable from the TDM container.

If authentication fails, search the TDM logs for `trigger`. A failure resembles:

```sh
fc.example.log:2026-01-01T00:00:00.000 +0000 WARN - FAIL send trigger to https://tds.example.test/thredds/admin/collection/trigger?trigger=never&collection=example status = 401
```

Use the reported status to narrow down the cause:

| Symptom                   | Likely area                                                                     |
|------------------------- |------------------------------------------------------------------------------- |
| HTTP `401`                | The `tdm` password does not match the password used to generate the TDS digest. |
| HTTP `403`                | The `tdm` user is authenticated but is missing the `tdsTrigger` role.           |
| Connection or TLS failure | Check `TDS_HOST`, DNS and network routing, and certificate trust.               |


<a id="h-0BAA13E6"></a>

## Citation

In order to cite this project, please simply make use of the Unidata THREDDS Data Server DOI: https://doi.org/10.5065/D6N014KG <https://doi.org/10.5065/D6N014KG>


<a id="h-7D1176D3"></a>

## Support

If you have a question or would like support for this TDM Docker container, consider [submitting a GitHub issue](https://github.com/Unidata/tdm-docker/issues). Alternatively, you may wish to start a discussion on the THREDDS Community mailing list: [thredds@unidata.ucar.edu](mailto:thredds@unidata.ucar.edu).

For general TDS questions, please see the [THREDDS support page](https://www.unidata.ucar.edu/software/tds/#help).
