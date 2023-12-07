# Docker Compose environment for Hopskotch Archive

The Docker Compose file defines a local deployment of the following components:

- archive-api: the archive API webserver (http://localhost:8000)
- archive-db: a PostgreSQL database for the archive metadata
- archive-ingest: the script that consumes Hopskotch messages and stores their metadata in the archive db and their payload in the object store
- object-store: an instance of MinIO for S3-compatible object storage for the archive data storage (http://localhost:9001/browser)

## Initialize the source repositories

Run the initialization script to clone the component source code repositories:

```bash
bash scripts/init.sh
```

## Obtain Hopskotch credentials

By default you will need to provide Hopskotch credentials `HOP_USERNAME` and `HOP_PASSWORD` in a `.env` file as illustrated in the `env.default` file. Any environment variables defined in `.env` will override the values specified in `env.default`. 

Obtain Hopskotch credentials for testing purposes from https://admin.dev.hop.scimma.org.

## Launch services using Docker Compose

Launch the services using Docker Compose by running

```bash
docker compose up -d
```

## Test the API server

Once online, you can find the UUID of an archived message by either browsing the logs of the ingest script

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

## Stop services and flush data

To terminate the services and purge all persistent data volumes, run

```bash
docker compose down --remove-orphans --volumes 
```
