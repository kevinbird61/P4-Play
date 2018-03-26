# create bridge
# bridge with default
docker network create --driver bridge p4_ipv4
# bridge with ipv6 enable
docker network create --driver bridge --ipv6 --subnet 2a02:6b8:b010:9020:1::/80 p4_ipv6