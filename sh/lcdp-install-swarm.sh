#!/usr/bin/env bash
# 服务器ip
ip="172.16.0.73"

#1. 准备文件，解压lcdp-install-swarm.gz。
tar zxvf lcdp-install-swarm.tar.gz
tar xvf Docker-ce.tar
tar xvf registry.tar
tar xvf temp.tar
#2. 安装docker ce；
yum install ./Docker-ce/docker-ce-19.03.9-3.el7.x86_64.rpm ./Docker-ce/docker-ce-cli-19.03.9-3.el7.x86_64.rpm ./Docker-ce/containerd.io-1.3.7-3.1.el7.x86_64.rpm

#3. 配置docker
sed -i "s/<IP>/$ip/g" ./temp/daemon.json
cp ./temp/daemon.json /etc/docker/daemon.json
#4. 安装镜像包
docker load < lcdp-images.tar

#5. 启动portainer；
docker stack deploy --compose-file=./temp/portainer-agent-stack.yml portainer
#暂时不启动gitlab，gitlab-runner；

#6. 启动registry，registry-ui；
sed -i "s/hostIp/$ip/g" ./registry/registry-config/simple.yml

docker service create \
--replicas 1 \
-p 5000:5000 \
--mount 'type=volume,src=./registry/registry-data,dst=/var/lib/registry' \
--mount 'type=volume,src=./registry/registry-config/simple.yml,dst=/etc/docker/registry/config.yml' \
registry:2

#ui
docker service create \
--replicas 1 \
-p 8880:80 \
-e "REGISTRY_TITLE=My Private Docker Registry" \
-e "URL=http://$ip:5000" \
joxit/docker-registry-ui:1.5

#7. 启动lcdp-one服务（前端，后端）；
docker service create \
--replicas 1 \
-p 18081:18081 \
-e "SPRING_PROFILES_ACTIVE=dev,swagger" \
-e "SPRING_SECURITY_USER_PASSWORD=admin" \
-e "JHIPSTER_REGISTRY_PASSWORD=admin" \
172.16.0.73:5000/lcdp-one:latest
