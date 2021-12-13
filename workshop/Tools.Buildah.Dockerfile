FROM docker.io/ubuntu:20.10

RUN apt-get update -qq \
    && apt-get -y install buildah \
    && apt-get install -y iptables
    # && add-apt-repository -y ppa:projectatomic/ppa \
    # && apt-get -qq -y install podman \
    # && apt-get install -qq -y software-properties-common uidmap \  
    # && apt-get update -qq \  

# Java
# *********** default-jdk -> openjdk-11-jdk ***************
RUN apt update \
    && apt install -y default-jdk

# *********** Basic tools *************** 
RUN apt-get update \
    && apt-get --assume-yes install curl \
    && apt-get --assume-yes install git-core \
    && apt-get --assume-yes install wget \
    && apt-get --assume-yes install gnupg2 \
    && apt-get --assume-yes install nano \
    && apt-get --assume-yes install apt-utils \
    && apt-get --assume-yes install unzip \
    && apt-get --assume-yes install zip

# Kubernetes
# *********** Kubernetes ***************
RUN apt-get update && apt-get install -y apt-transport-https \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl

# *********** IBM Cloud CLI *********** 
RUN  curl -fsSL https://clis.cloud.ibm.com/install/linux | sh \
     && ibmcloud plugin install container-service \
     && ibmcloud plugin install container-registry

# Docker CLI
# *********** Docker *************** "
WORKDIR /
RUN apt install -y gnupg  \
    && apt install -y docker.io \
    && docker --version

# To keep it running
# CMD tail -f /dev/null