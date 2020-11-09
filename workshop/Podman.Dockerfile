# You can use following commands 
# to build and run the image on your local PC:
# =====================================
# $ docker build -t cns-tools-image:v1 . 
# $ docker run -it cns-tools-image:v1 

FROM ubuntu:latest

RUN echo "*********** Init *************** "
RUN apt-get update \
    && apt-get --assume-yes install curl \
    && apt-get --assume-yes install git-core \
    && apt-get --assume-yes install wget \
# editor
    && apt-get --assume-yes install nano \
# setup network tools
    && apt-get --assume-yes install apt-utils \
# RUN apt-get --assume-yes install net-tools
# zip
    && apt-get --assume-yes install unzip \
    && apt-get --assume-yes install zip \
# Needed for Podman installlation    
    && DEBIAN_FRONTEND="noninteractive" apt-get --assume-yes install tzdata


# Cloud-Native-Starter -project
# https://github.com/IBM/cloud-native-starter/blob/master/workshop/00-prerequisites.md
# Clone/Install
# =============
# RUN mkdir usr/cns
# WORKDIR /usr/cns
# RUN git clone https://github.com/IBM/cloud-native-starter.git
# WORKDIR /usr/cns/cloud-native-starter
# RUN chmod u+x ./iks-scripts/*.sh
# Copy local.env
# RUN cp template.local.env local.env
# WORKDIR /usr/cns/cloud-native-starter/workshop
# RUN curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.5 sh -

# -----------
# Docker (replaced with podman)
# -----------

# WORKDIR /
# RUN apt install -y gnupg
# RUN apt install -y docker.io 
# RUN docker --version

# -----------
# Podman
# -----------

RUN echo "*********** selinux *************** "  
RUN apt-get update \
    && apt-get --assume-yes install libselinux1 \
    && apt-get --assume-yes install selinux-basics 
    # && apt-get --assume-yes install selinux-uti

RUN echo "*********** auditd *************** "  
RUN apt-get update \
    && apt-get --assume-yes install auditd \
    && apt-get --assume-yes install audispd-plugins


RUN echo "*********** Podman *************** "
RUN adduser root sudo
RUN apt-get --assume-yes install sudo
RUN apt-get update -qq \
    && apt-get install -qq -y software-properties-common uidmap \
    # && add-apt-repository -y ppa:projectatomic/ppa \
    && . /etc/os-release \
    && echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list \
    && curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | apt-key add - \
    && apt-get update -qq \
    # Build
    && apt-get --assume-yes install buildah \
    # Run command
    && apt-get update -qq \
    && apt-get --assume-yes install runc \
    # Network
    && apt-get update -qq \
    && apt-get --assume-yes install slirp4netns \
    && apt-get update -qq \
    && apt-get --assume-yes install podman \
    && apt-get --assume-yes install iptables \
    && rm -rf ~/.config/containers

# -----------
# Kubernetes
# -----------

RUN echo "*********** Kubernetes *************** "
RUN apt-get update && apt-get install -y apt-transport-https \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl 

# -----------
# IBM Cloud CLI
# -----------

RUN echo "*********** IBM Cloud CLI *************** "
# RUN  curl -sL http://ibm.biz/idt-installer | bash # Full installation in not needed in that case
# https://cloud.ibm.com/docs/cli?topic=cloud-cli-install-ibmcloud-cli
RUN  curl -fsSL https://clis.cloud.ibm.com/install/linux | sh \
     && ibmcloud plugin install container-service \
     && ibmcloud plugin install container-registry

# RedHat OpenShift CLI oc

RUN echo "*********** RedHat OpenShift CLI oc *************** "
WORKDIR /tmp
RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.5/linux/oc.tar.gz \
    && tar -zxvf oc.tar.gz \
    && mv oc /usr/local/bin/oc 

# Expose Ports
#kiali
EXPOSE 20001

