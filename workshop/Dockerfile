# You can use following commands 
# to build and run the image on your local PC:
# =====================================
# $ docker build -t cns-tools-image:v1 . 
# $ docker run -it cns-tools-image:v1 

FROM ubuntu:latest

RUN apt update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y tzdata

#Java
RUN echo "*********** default-jdk -> openjdk-11-jdk *************** "
RUN apt update \
    && apt install -y default-jdk

RUN echo "*********** Basic tools *************** "
RUN apt-get update \
    && apt-get --assume-yes install curl \
    && apt-get --assume-yes install git-core \
    && apt-get --assume-yes install wget

# editor
RUN apt-get --assume-yes install nano

# setup network tools
RUN apt-get --assume-yes install apt-utils

# RUN apt-get --assume-yes install net-tools
# zip
RUN apt-get --assume-yes install unzip \
    && apt-get --assume-yes install zip


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

#Docker CLI
RUN echo "*********** Docker *************** "
WORKDIR /
RUN apt install -y gnupg  \
    && apt install -y docker.io \
    && docker --version

#Maven
RUN echo "*********** Maven *************** "
RUN apt update \
    && apt install -y maven

#Kubernetes
RUN echo "*********** Kubernetes *************** "
RUN apt-get update && apt-get install -y apt-transport-https \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl

# IBM Cloud CLI

# RUN  curl -sL http://ibm.biz/idt-installer | bash # Full installation in not needed in that case
# https://cloud.ibm.com/docs/cli?topic=cloud-cli-install-ibmcloud-cli
RUN echo "*********** IBM Cloud CLI *************** "
RUN  curl -fsSL https://clis.cloud.ibm.com/install/linux | sh \
     && ibmcloud plugin install container-service \
     && ibmcloud plugin install container-registry

# RedHat OpenShift cli OC
RUN echo "*********** RedHat OpenShift CLI*************** "
WORKDIR /tmp
RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.5/linux/oc.tar.gz \
    && tar -zxvf oc.tar.gz \
    && mv oc /usr/local/bin/oc

# Expose Ports
#kiali
EXPOSE 20001

