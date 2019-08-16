# Jenkins Agent Docker image with customisable Jenkins slave agent

A usable Docker container with 
- Bitnami Java
- Bitnami PHP
- a copy of Jenkins slave.jar

## Setup
1. Clone this repo

2. Make a copy of .env from .env-example
```
$ cp .env-example .env
```

3. Modify .env to suit

4. An example Docker Compose file is included, deploy & daemonise the container with the included Docker Compose file.
   In most cases, this is not necessary, however modify docker-compose.yml file if required
```
docker-compose up -d
```

## References
- [Bitnami Java Docker Image](https://bit.ly/2Zcxn5u)
- [Jenkins JNLP Agent Docker image](https://dockr.ly/2NaXQOf)
