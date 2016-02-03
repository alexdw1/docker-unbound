docker stop unbound
docker rm unbound
docker build -t alexdw1/unbound .
docker run --hostname unbound --name unbound -it -p 151.80.177.19:53:53 -p 151.80.177.19:53:53/udp alexdw1/unbound

