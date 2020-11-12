# *************************************
#   DOESN'T WORK
#   See this entry: https://github.com/containers/podman/issues/8275
# *************************************
FROM fedora:latest

# -----------
# Install basics
# -----------
# RUN dnf -y install apt
RUN dnf  -y install git-core
RUN dnf  -y upgrade --refresh
RUN dnf  -y install nano
RUN dnf  -y upgrade --refresh
RUN dnf  -y install wget
RUN dnf  -y upgrade --refresh
# RUN dnf  -y install fuse-overlay
# RUN dnf  -y upgrade --refresh
RUN dnf remove fuse-overlayfs
RUN dnf  -y upgrade --refresh

# -----------
# Podman/buildah
# -----------
RUN dnf  -y install podman
RUN dnf  -y upgrade --refresh
RUN dnf  install buildah sudo -y
RUN dnf  -y upgrade --refresh



# -----------
# Kubernetes
# -----------
# https://snapcraft.io/install/kubectl/fedora
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl
RUN kubectl version --client

# -----------
# IBM Cloud CLI
# -----------
# RUN  curl -sL http://ibm.biz/idt-installer | bash # Full installation in not needed in that case
# https://cloud.ibm.com/docs/cli?topic=cloud-cli-install-ibmcloud-cli
RUN  curl -fsSL https://clis.cloud.ibm.com/install/linux | sh \
     && ibmcloud plugin install container-service \
     && ibmcloud plugin install container-registry
# -----------
# RedHat OpenShift CLI oc
# -----------
RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.5/linux/oc.tar.gz \
    && tar -zxvf oc.tar.gz \
    && mv oc /usr/local/bin/oc 