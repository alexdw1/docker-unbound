docker stop unbound
docker rm unbound
docker build -t alexdw1/unbound .
docker run --hostname unbound -v /persistant:/persistant --net=rednet --name unbound -it alexdw1/unbound $1

