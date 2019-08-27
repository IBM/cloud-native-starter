FROM ubuntu

RUN apt-get update
RUN apt-get --assume-yes install curl
RUN apt-get --assume-yes install git-core
RUN apt-get --assume-yes install wget
# editor
RUN apt-get --assume-yes install nano
# setup network tools
RUN apt-get --assume-yes install apt-utils
RUN apt-get --assume-yes install net-tools
# zip
RUN apt-get --assume-yes install unzip
RUN apt-get --assume-yes install zip

RUN pwd

# Cloud-Native-Starter -project
# https://github.com/IBM/cloud-native-starter/blob/master/workshop/00-prerequisites.md
# Install
RUN mkdir usr/cns
WORKDIR /usr/cns
RUN git clone https://github.com/IBM/cloud-native-starter.git
WORKDIR /usr/cns/cloud-native-starter
RUN chmod u+x ./iks-scripts/*.sh
# Copy local.env
RUN cp template.local.env local.env
WORKDIR /usr/cns/cloud-native-starter/workshop
RUN curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.5 sh -

#Docker
WORKDIR /
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh

RUN docker --version

# Docker
RUN apt-get update
# RUN apt-get --assume-yes install docker-ce 
RUN apt-get --assume-yes install docker-ce-cli 
# RUN apt-get --assume-yes install containerd.io
# RUN dockerd

#Kubernetes
RUN apt-get update && apt-get install -y apt-transport-https
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl

# IBM Cloud CLI
# RUN  curl -sL http://ibm.biz/idt-installer | bash # Full installation in not needed in that case
# https://cloud.ibm.com/docs/cli?topic=cloud-cli-install-ibmcloud-cli
RUN  curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
RUN ibmcloud plugin install container-service
RUN ibmcloud plugin install container-registry

#kiali
EXPOSE 20001
#grafana 
# EXPOSE 3000
#jaeger
# EXPOSE 16686
#prometheus
# EXPOSE 9090

