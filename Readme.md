# Docker Compose environment for Hopskotch Archive

This repo contains a Docker-based testing and development harness for the components of the Hopskotch Archive system, including the core Python package [`archive-core`](https://github.com/scimma/archive-core), the Hopkotch message ingest service [`archive-ingest`](https://github.com/scimma/archive-ingest), and the API server [`archive-api`](https://github.com/scimma/archive-api) that provides a RESTful interface to the archive database.

## General instructions

### Initialize the source repositories

Run the initialization script to clone the component source code repositories and build images:

```bash
bash scripts/init.sh
```

### Obtain Hopskotch credentials

By default you will need to provide Hopskotch credentials `HOP_USERNAME` and `HOP_PASSWORD` in a `.env` file as illustrated in the `env.default` file. Any environment variables defined in `.env` will override the values specified in `env.default`. 

Obtain Hopskotch credentials for testing purposes from https://admin.dev.hop.scimma.org.

### Launch and destroy services using Docker Compose

Launch the services and follow the service logs by running

```bash
docker compose -f docker-compose.$COMPONENT.yaml up -d
docker compose logs -f
```

To terminate the services and purge all persistent data volumes, run

```bash
docker compose down --remove-orphans --volumes 
```

## Component testing and development

### Archive core Python package

The Docker Compose file `docker-compose.archive-core.yaml` defines a local deployment of the following components:

- archive-core: a container with the archive-core package installed and test definitions
- archive-core-db: a PostgreSQL database used by the archive-core test suite

Execute the tests by running:

```bash
docker compose -f docker-compose.archive-core.yaml up
```

### Archive ingester and API server

The Docker Compose file `docker-compose.archive-api.yaml` defines a local deployment of the following components:

- archive-api: the archive API webserver (http://localhost:8000)
- archive-db: a PostgreSQL database for the archive metadata
- archive-ingest: the script that consumes Hopskotch messages and stores their metadata in the archive db and their payload in the object store
- object-store: an instance of MinIO for S3-compatible object storage for the archive data storage (http://localhost:9001/browser)

Launch the services with:

```bash
docker compose -f docker-compose.archive-api.yaml up
```

Note: The `archive-ingest` and `archive-api` images should have already been built by the `init.sh` script using the `make` commands in their respective source code repos. The `archive-core` component in this case does not have its own container; instead, its source code is mounted at runtime into the `archive-ingest` and `archive-api` containers so that host-level changes to the core package code can be applied by simply restarting the `archive-ingest` and `archive-api` services, when the core package is reinstalled via `pip`. You can restart services like so:

```bash
docker compose -f docker-compose.archive-api.yaml restart archive-api archive-ingest
```

Once online, you can find the UUID of an archived message by either browsing the logs of the ingest script:

```bash
docker compose logs archive-ingest
```

or by [logging into the MinIO browser](http://localhost:9001/browser). Then you can fetch that message's contents via the archive API using the `client_httpx.py` utility script like so (where you must first source the `.env` file to set the `HOP_USERNAME` and `HOP_PASSWORD` environment variables):

```bash
$ source .env
$ python scripts/client_httpx.py 21dad234-126d-4ebe-a8ce-53ecf072b12e

first response: ...
second response: ...
final response:
  status: 200
  headers: Headers({'date': 'Fri, 20 Oct 2023 19:48:32 GMT', 'server': 'uvicorn', 'authentication-info': 'sid=..., data=...', 'transfer-encoding': 'chunked'})
Response size: 3881
Response content:
{
  'message': {'format': 'voevent', 
  'content': b'{
    "ivorn": "ivo://nasa.gsfc.gcn/SWIFT#Actual_Point_Dir_2023-10-20T19:47:01.26_623869523-907", 
    "role": "utility"', ... , 'con_message_crc32': 1391718911, 'duplicate': False
    }
 }
```
