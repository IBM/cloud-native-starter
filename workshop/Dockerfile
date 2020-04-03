# You can use following commands 
# to build and run the image on your local PC:
# =====================================
# $ docker build -t cns-tools-image:v1 . 
# $ docker run -it cns-tools-image:v1 

FROM ubuntu

RUN apt-get update
RUN apt-get --assume-yes install curl
RUN apt-get --assume-yes install git-core
RUN apt-get --assume-yes install wget
# editor
RUN apt-get --assume-yes install nano
# setup network tools
RUN apt-get --assume-yes install apt-utils
# RUN apt-get --assume-yes install net-tools
# zip
RUN apt-get --assume-yes install unzip
RUN apt-get --assume-yes install zip


# Cloud-Native-Starter -project
# https://github.com/IBM/cloud-native-starter/blob/master/workshop/00-prerequisites.md
# Install
# RUN mkdir usr/cns
# WORKDIR /usr/cns
# RUN git clone https://github.com/IBM/cloud-native-starter.git
# WORKDIR /usr/cns/cloud-native-starter
# RUN chmod u+x ./iks-scripts/*.sh
# Copy local.env
# RUN cp template.local.env local.env
# WORKDIR /usr/cns/cloud-native-starter/workshop
# RUN curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.5 sh -

#Docker
WORKDIR /
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh
RUN docker --version

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

# RedHat OpenShift cli OC
WORKDIR /tmp
RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.5/linux/oc.tar.gz
RUN tar -zxvf oc.tar.gz
RUN mv oc /usr/local/bin/oc

# Expose Ports
#kiali
EXPOSE 20001

