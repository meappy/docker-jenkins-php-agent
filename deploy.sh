docker network create --driver=overlay --attachable jenkins-privnet
docker stack deploy -c <(docker-compose -f docker-compose.yml config) jenkins
